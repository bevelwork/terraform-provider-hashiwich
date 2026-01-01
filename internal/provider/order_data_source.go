package provider

import (
	"context"

	"github.com/hashicorp/terraform-plugin-framework/attr"
	"github.com/hashicorp/terraform-plugin-framework/datasource"
	"github.com/hashicorp/terraform-plugin-framework/datasource/schema"
	"github.com/hashicorp/terraform-plugin-framework/types"
	"github.com/hashicorp/terraform-plugin-log/tflog"
)

// Ensure provider defined types fully satisfy framework interfaces.
var _ datasource.DataSource = &OrderDataSource{}

func NewOrderDataSource() datasource.DataSource {
	return &OrderDataSource{}
}

// OrderDataSource defines the data source implementation.
type OrderDataSource struct {
	client any
}

// OrderDataSourceModel describes the data source data model.
type OrderDataSourceModel struct {
	Sandwich types.Object `tfsdk:"sandwich"`
	Drink    types.Object `tfsdk:"drink"`
	Id       types.String `tfsdk:"id"`
}

func (d *OrderDataSource) Metadata(ctx context.Context, req datasource.MetadataRequest, resp *datasource.MetadataResponse) {
	resp.TypeName = req.ProviderTypeName + "_order"
}

func (d *OrderDataSource) Schema(ctx context.Context, req datasource.SchemaRequest, resp *datasource.SchemaResponse) {
	resp.Schema = schema.Schema{
		MarkdownDescription: "Mock data source that returns an order with sandwich and drink specifications for instructional purposes",

		Attributes: map[string]schema.Attribute{
			"sandwich": schema.SingleNestedAttribute{
				Attributes: map[string]schema.Attribute{
					"bread": schema.StringAttribute{
						MarkdownDescription: "The bread type",
						Computed:            true,
					},
					"meat": schema.StringAttribute{
						MarkdownDescription: "The meat type",
						Computed:            true,
					},
					"name": schema.StringAttribute{
						MarkdownDescription: "The sandwich name",
						Computed:            true,
					},
				},
				MarkdownDescription: "Sandwich specifications",
				Computed:            true,
			},
			"drink": schema.SingleNestedAttribute{
				Attributes: map[string]schema.Attribute{
					"kind": schema.StringAttribute{
						MarkdownDescription: "The drink kind",
						Computed:            true,
					},
					"ice": schema.ListNestedAttribute{
						NestedObject: schema.NestedAttributeObject{
							Attributes: map[string]schema.Attribute{
								"some": schema.BoolAttribute{
									MarkdownDescription: "Some ice",
									Computed:            true,
								},
								"lots": schema.BoolAttribute{
									MarkdownDescription: "Lots of ice",
									Computed:            true,
								},
								"max": schema.BoolAttribute{
									MarkdownDescription: "Maximum ice",
									Computed:            true,
								},
							},
						},
						MarkdownDescription: "Ice configuration",
						Computed:            true,
					},
				},
				MarkdownDescription: "Drink specifications",
				Computed:            true,
			},
			"id": schema.StringAttribute{
				MarkdownDescription: "Data source identifier",
				Computed:            true,
			},
		},
	}
}

func (d *OrderDataSource) Configure(ctx context.Context, req datasource.ConfigureRequest, resp *datasource.ConfigureResponse) {
	// Prevent panic if the provider has not been configured.
	if req.ProviderData == nil {
		return
	}

	d.client = req.ProviderData
}

func (d *OrderDataSource) Read(ctx context.Context, req datasource.ReadRequest, resp *datasource.ReadResponse) {
	var data OrderDataSourceModel

	// Read Terraform configuration data into the model
	resp.Diagnostics.Append(req.Config.Get(ctx, &data)...)

	if resp.Diagnostics.HasError() {
		return
	}

	// Mock order data - example order with sandwich and drink specifications
	sandwichSpec := map[string]attr.Value{
		"bread": types.StringValue("rye"),
		"meat":  types.StringValue("turkey"),
		"name":  types.StringValue("turkey on rye"),
	}

	iceSpec := map[string]attr.Value{
		"some": types.BoolValue(false),
		"lots": types.BoolValue(true),
		"max":  types.BoolValue(false),
	}

	iceList := []attr.Value{
		types.ObjectValueMust(
			map[string]attr.Type{
				"some": types.BoolType,
				"lots": types.BoolType,
				"max":  types.BoolType,
			},
			iceSpec,
		),
	}

	ice, diags := types.ListValue(
		types.ObjectType{
			AttrTypes: map[string]attr.Type{
				"some": types.BoolType,
				"lots": types.BoolType,
				"max":  types.BoolType,
			},
		},
		iceList,
	)
	if diags.HasError() {
		resp.Diagnostics.Append(diags...)
		return
	}

	drinkSpec := map[string]attr.Value{
		"kind": types.StringValue("cola"),
		"ice":  ice,
	}

	sandwich, diags := types.ObjectValue(
		map[string]attr.Type{
			"bread": types.StringType,
			"meat":  types.StringType,
			"name":  types.StringType,
		},
		sandwichSpec,
	)
	resp.Diagnostics.Append(diags...)
	if resp.Diagnostics.HasError() {
		return
	}

	drink, diags := types.ObjectValue(
		map[string]attr.Type{
			"kind": types.StringType,
			"ice": types.ListType{
				ElemType: types.ObjectType{
					AttrTypes: map[string]attr.Type{
						"some": types.BoolType,
						"lots": types.BoolType,
						"max":  types.BoolType,
					},
				},
			},
		},
		drinkSpec,
	)
	resp.Diagnostics.Append(diags...)
	if resp.Diagnostics.HasError() {
		return
	}

	data.Sandwich = sandwich
	data.Drink = drink
	data.Id = types.StringValue("order")

	tflog.Trace(ctx, "read order data source")

	// Save data into Terraform state
	resp.Diagnostics.Append(resp.State.Set(ctx, &data)...)
}

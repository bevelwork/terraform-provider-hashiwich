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
var _ datasource.DataSource = &DeliMeatsDataSource{}

func NewDeliMeatsDataSource() datasource.DataSource {
	return &DeliMeatsDataSource{}
}

// DeliMeatsDataSource defines the data source implementation.
type DeliMeatsDataSource struct {
	client any
}

// DeliMeatsDataSourceModel describes the data source data model.
type DeliMeatsDataSourceModel struct {
	Meats types.List   `tfsdk:"meats"`
	Id    types.String `tfsdk:"id"`
}

func (d *DeliMeatsDataSource) Metadata(ctx context.Context, req datasource.MetadataRequest, resp *datasource.MetadataResponse) {
	resp.TypeName = req.ProviderTypeName + "_deli_meats"
}

func (d *DeliMeatsDataSource) Schema(ctx context.Context, req datasource.SchemaRequest, resp *datasource.SchemaResponse) {
	resp.Schema = schema.Schema{
		MarkdownDescription: "Mock data source that returns a list of deli meats for instructional purposes",

		Attributes: map[string]schema.Attribute{
			"meats": schema.ListAttribute{
				ElementType:         types.StringType,
				MarkdownDescription: "List of available deli meats",
				Computed:            true,
			},
			"id": schema.StringAttribute{
				MarkdownDescription: "Data source identifier",
				Computed:            true,
			},
		},
	}
}

func (d *DeliMeatsDataSource) Configure(ctx context.Context, req datasource.ConfigureRequest, resp *datasource.ConfigureResponse) {
	// Prevent panic if the provider has not been configured.
	if req.ProviderData == nil {
		return
	}

	d.client = req.ProviderData
}

func (d *DeliMeatsDataSource) Read(ctx context.Context, req datasource.ReadRequest, resp *datasource.ReadResponse) {
	var data DeliMeatsDataSourceModel

	// Read Terraform configuration data into the model
	resp.Diagnostics.Append(req.Config.Get(ctx, &data)...)

	if resp.Diagnostics.HasError() {
		return
	}

	// Mock data - list of deli meats
	meatsList := []string{
		"turkey",
		"ham",
		"roast beef",
		"chicken",
		"pastrami",
		"corned beef",
		"salami",
		"bologna",
		"mortadella",
		"prosciutto",
		"pepperoni",
		"capicola",
		"tuna salad",
		"chicken salad",
		"egg salad",
		"turkey breast",
		"roast pork",
		"liverwurst",
		"braunschweiger",
		"pâté",
		"smoked salmon",
	}

	// Convert to Terraform types
	meatsValues := make([]attr.Value, len(meatsList))
	for i, meat := range meatsList {
		meatsValues[i] = types.StringValue(meat)
	}

	meats, diags := types.ListValue(types.StringType, meatsValues)
	resp.Diagnostics.Append(diags...)
	if resp.Diagnostics.HasError() {
		return
	}

	data.Meats = meats
	data.Id = types.StringValue("deli-meats")

	tflog.Trace(ctx, "read deli_meats data source")

	// Save data into Terraform state
	resp.Diagnostics.Append(resp.State.Set(ctx, &data)...)
}

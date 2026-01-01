package provider

import (
	"context"
	"math/big"

	"github.com/hashicorp/terraform-plugin-framework/attr"
	"github.com/hashicorp/terraform-plugin-framework/datasource"
	"github.com/hashicorp/terraform-plugin-framework/datasource/schema"
	"github.com/hashicorp/terraform-plugin-framework/types"
	"github.com/hashicorp/terraform-plugin-log/tflog"
)

// Ensure provider defined types fully satisfy framework interfaces.
var _ datasource.DataSource = &MenuDataSource{}

func NewMenuDataSource() datasource.DataSource {
	return &MenuDataSource{}
}

// MenuDataSource defines the data source implementation.
type MenuDataSource struct {
	client *ProviderConfig
}

// MenuDataSourceModel describes the data source data model.
type MenuDataSourceModel struct {
	Prices types.Object `tfsdk:"prices"`
	Id     types.String `tfsdk:"id"`
}

func (d *MenuDataSource) Metadata(ctx context.Context, req datasource.MetadataRequest, resp *datasource.MetadataResponse) {
	resp.TypeName = req.ProviderTypeName + "_menu"
}

func (d *MenuDataSource) Schema(ctx context.Context, req datasource.SchemaRequest, resp *datasource.SchemaResponse) {
	resp.Schema = schema.Schema{
		MarkdownDescription: "Mock menu data source that returns base prices for all resources (before upcharge)",

		Attributes: map[string]schema.Attribute{
			"prices": schema.SingleNestedAttribute{
				Attributes: map[string]schema.Attribute{
					"sandwich": schema.NumberAttribute{
						MarkdownDescription: "Base price of a sandwich",
						Computed:            true,
					},
					"drink": schema.NumberAttribute{
						MarkdownDescription: "Base price of a drink",
						Computed:            true,
					},
					"soup": schema.NumberAttribute{
						MarkdownDescription: "Base price of a soup",
						Computed:            true,
					},
					"salad": schema.NumberAttribute{
						MarkdownDescription: "Base price of a salad",
						Computed:            true,
					},
					"cookie": schema.NumberAttribute{
						MarkdownDescription: "Base price of a cookie",
						Computed:            true,
					},
					"brownie": schema.NumberAttribute{
						MarkdownDescription: "Base price of a brownie",
						Computed:            true,
					},
					"stroopwafel": schema.NumberAttribute{
						MarkdownDescription: "Base price of a stroopwafel",
						Computed:            true,
					},
					"napkin": schema.NumberAttribute{
						MarkdownDescription: "Base price per napkin",
						Computed:            true,
					},
					"cracker": schema.NumberAttribute{
						MarkdownDescription: "Base price per cracker pack",
						Computed:            true,
					},
					"silverware": schema.NumberAttribute{
						MarkdownDescription: "Base price per silverware pack",
						Computed:            true,
					},
					"dogtreat_small": schema.NumberAttribute{
						MarkdownDescription: "Base price of a small dog treat",
						Computed:            true,
					},
					"dogtreat_large": schema.NumberAttribute{
						MarkdownDescription: "Base price of a large dog treat",
						Computed:            true,
					},
				},
				MarkdownDescription: "Base prices for all menu items (before upcharge)",
				Computed:            true,
			},
			"id": schema.StringAttribute{
				MarkdownDescription: "Data source identifier",
				Computed:            true,
			},
		},
	}
}

func (d *MenuDataSource) Configure(ctx context.Context, req datasource.ConfigureRequest, resp *datasource.ConfigureResponse) {
	// Prevent panic if the provider has not been configured.
	if req.ProviderData == nil {
		d.client = nil
		return
	}

	config, ok := req.ProviderData.(*ProviderConfig)
	if !ok {
		// If it's not ProviderConfig, create a default one (no upcharge)
		d.client = &ProviderConfig{
			Upcharge: big.NewFloat(0.0),
		}
		return
	}

	d.client = config
}

func (d *MenuDataSource) Read(ctx context.Context, req datasource.ReadRequest, resp *datasource.ReadResponse) {
	var data MenuDataSourceModel

	// Read Terraform configuration data into the model
	resp.Diagnostics.Append(req.Config.Get(ctx, &data)...)

	if resp.Diagnostics.HasError() {
		return
	}

	// Base prices (before upcharge)
	basePrices := map[string]attr.Value{
		"sandwich":      types.NumberValue(big.NewFloat(5.00)),
		"drink":         types.NumberValue(big.NewFloat(1.00)),
		"soup":          types.NumberValue(big.NewFloat(2.50)),
		"salad":         types.NumberValue(big.NewFloat(4.00)),
		"cookie":        types.NumberValue(big.NewFloat(1.50)),
		"brownie":       types.NumberValue(big.NewFloat(2.00)),
		"stroopwafel":   types.NumberValue(big.NewFloat(1.75)),
		"napkin":        types.NumberValue(big.NewFloat(0.25)),
		"cracker":       types.NumberValue(big.NewFloat(0.50)),
		"silverware":    types.NumberValue(big.NewFloat(1.00)),
		"dogtreat_small": types.NumberValue(big.NewFloat(1.00)),
		"dogtreat_large": types.NumberValue(big.NewFloat(2.00)),
	}

	// Apply upcharge if provider config is available
	if d.client != nil && d.client.Upcharge != nil && d.client.Upcharge.Sign() != 0 {
		for key, basePrice := range basePrices {
			base := basePrice.(types.Number).ValueBigFloat()
			finalPrice := ApplyUpcharge(base, d.client.Upcharge)
			basePrices[key] = types.NumberValue(finalPrice)
		}
	}

	prices, diags := types.ObjectValue(
		map[string]attr.Type{
			"sandwich":      types.NumberType,
			"drink":         types.NumberType,
			"soup":          types.NumberType,
			"salad":         types.NumberType,
			"cookie":        types.NumberType,
			"brownie":       types.NumberType,
			"stroopwafel":   types.NumberType,
			"napkin":        types.NumberType,
			"cracker":       types.NumberType,
			"silverware":    types.NumberType,
			"dogtreat_small": types.NumberType,
			"dogtreat_large": types.NumberType,
		},
		basePrices,
	)
	resp.Diagnostics.Append(diags...)
	if resp.Diagnostics.HasError() {
		return
	}

	data.Prices = prices
	data.Id = types.StringValue("menu")

	tflog.Trace(ctx, "read menu data source")

	// Save data into Terraform state
	resp.Diagnostics.Append(resp.State.Set(ctx, &data)...)
}

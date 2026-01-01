package provider

import (
	"context"
	"math/big"

	"github.com/hashicorp/terraform-plugin-framework/action"
	"github.com/hashicorp/terraform-plugin-framework/datasource"
	"github.com/hashicorp/terraform-plugin-framework/ephemeral"
	"github.com/hashicorp/terraform-plugin-framework/function"
	"github.com/hashicorp/terraform-plugin-framework/provider"
	"github.com/hashicorp/terraform-plugin-framework/provider/schema"
	"github.com/hashicorp/terraform-plugin-framework/resource"
	"github.com/hashicorp/terraform-plugin-framework/types"
)

// Ensure hwProvider satisfies various provider interfaces.
var _ provider.Provider = &hwProvider{}
var _ provider.ProviderWithFunctions = &hwProvider{}
var _ provider.ProviderWithEphemeralResources = &hwProvider{}
var _ provider.ProviderWithActions = &hwProvider{}

// hwProvider defines the provider implementation.
type hwProvider struct {
	// version is set to the provider version on release, "dev" when the
	// provider is built and ran locally, and "test" when running acceptance
	// testing.
	version string
}

// hwProviderModel describes the provider data model.
type hwProviderModel struct {
	Endpoint types.String `tfsdk:"endpoint"`
	Upcharge types.Number `tfsdk:"upcharge"`
}

// ProviderConfig holds the provider configuration data passed to resources
type ProviderConfig struct {
	Upcharge *big.Float
}

// ApplyUpcharge applies the upcharge flat amount to a base price
// upcharge is a flat dollar amount added to the base price
func ApplyUpcharge(basePrice *big.Float, upcharge *big.Float) *big.Float {
	if upcharge == nil || upcharge.Sign() == 0 {
		return basePrice
	}
	
	var result big.Float
	// Calculate: basePrice + upcharge
	result.Add(basePrice, upcharge)
	return &result
}

func (p *hwProvider) Metadata(ctx context.Context, req provider.MetadataRequest, resp *provider.MetadataResponse) {
	resp.TypeName = "hw"
	resp.Version = p.version
}

func (p *hwProvider) Schema(ctx context.Context, req provider.SchemaRequest, resp *provider.SchemaResponse) {
	resp.Schema = schema.Schema{
		Attributes: map[string]schema.Attribute{
			"endpoint": schema.StringAttribute{
				MarkdownDescription: "Example provider attribute",
				Optional:            true,
			},
			"upcharge": schema.NumberAttribute{
				MarkdownDescription: "Flat dollar amount to add to all resource prices (e.g., 0.50 adds $0.50 to each item, 1.00 adds $1.00)",
				Optional:            true,
			},
		},
	}
}

func (p *hwProvider) Configure(ctx context.Context, req provider.ConfigureRequest, resp *provider.ConfigureResponse) {
	var data hwProviderModel

	resp.Diagnostics.Append(req.Config.Get(ctx, &data)...)

	if resp.Diagnostics.HasError() {
		return
	}

	// Extract upcharge value (default to 0 if not provided)
	var upcharge *big.Float
	if data.Upcharge.IsNull() || data.Upcharge.IsUnknown() {
		upcharge = big.NewFloat(0.0)
	} else {
		upcharge = data.Upcharge.ValueBigFloat()
	}

	// Create provider config with upcharge
	config := &ProviderConfig{
		Upcharge: upcharge,
	}

	// Pass config to both resources and data sources (for menu pricing with upcharge)
	resp.DataSourceData = config
	resp.ResourceData = config
}

func (p *hwProvider) Resources(ctx context.Context) []func() resource.Resource {
	return []func() resource.Resource{
		NewBreadResource,
		NewMeatResource,
		NewSandwichResource,
		NewBagResource,
		NewDrinkResource,
		NewSoupResource,
		NewSaladResource,
		NewNapkinResource,
		NewCrackerResource,
		NewSilverwareResource,
		NewDogtreatResource,
		NewCookieResource,
		NewBrownieResource,
		NewStroopwafelResource,
		NewOvenResource,
		NewCookResource,
		NewTablesResource,
		NewChairsResource,
		NewFridgeResource,
		NewStoreResource,
	}
}

func (p *hwProvider) EphemeralResources(ctx context.Context) []func() ephemeral.EphemeralResource {
	return []func() ephemeral.EphemeralResource{}
}

func (p *hwProvider) DataSources(ctx context.Context) []func() datasource.DataSource {
	return []func() datasource.DataSource{
		NewDeliMeatsDataSource,
		NewCondimentsDataSource,
		NewOrderDataSource,
		NewMenuDataSource,
	}
}

func (p *hwProvider) Functions(ctx context.Context) []func() function.Function {
	return []func() function.Function{}
}

func (p *hwProvider) Actions(ctx context.Context) []func() action.Action {
	return []func() action.Action{}
}

func New(version string) func() provider.Provider {
	return func() provider.Provider {
		return &hwProvider{
			version: version,
		}
	}
}

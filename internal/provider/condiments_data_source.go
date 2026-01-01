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
var _ datasource.DataSource = &CondimentsDataSource{}

func NewCondimentsDataSource() datasource.DataSource {
	return &CondimentsDataSource{}
}

// CondimentsDataSource defines the data source implementation.
type CondimentsDataSource struct {
	client any
}

// CondimentsDataSourceModel describes the data source data model.
type CondimentsDataSourceModel struct {
	Condiments types.List   `tfsdk:"condiments"`
	Id         types.String `tfsdk:"id"`
}

func (d *CondimentsDataSource) Metadata(ctx context.Context, req datasource.MetadataRequest, resp *datasource.MetadataResponse) {
	resp.TypeName = req.ProviderTypeName + "_condiments"
}

func (d *CondimentsDataSource) Schema(ctx context.Context, req datasource.SchemaRequest, resp *datasource.SchemaResponse) {
	resp.Schema = schema.Schema{
		MarkdownDescription: `A flavorful data source that returns a comprehensive list of available condiments. Perfect for learning how data sources work and how to query read-only information that enhances your sandwich configurations.

**Example Usage:**

` + "```hcl" + `
# Get all available condiments
data "hw_condiments" "all" {}

# Use the condiments in outputs
output "available_condiments" {
  value = data.hw_condiments.all.condiments
}

# Use condiments to create resources or make decisions
locals {
  condiment_list = data.hw_condiments.all.condiments
  has_mayo       = contains(local.condiment_list, "mayonnaise")
  has_mustard    = contains(local.condiment_list, "mustard")
}

# Example: Use in conditional logic
resource "hw_sandwich" "with_condiments" {
  count = local.has_mayo ? 1 : 0
  
  bread_id = hw_bread.rye.id
  meat_id  = hw_meat.turkey.id
  description = "Turkey sandwich with available condiments"
}

# Example: Iterate over condiments
output "condiment_count" {
  value = length(data.hw_condiments.all.condiments)
}

output "condiment_list" {
  value = [
    for condiment in data.hw_condiments.all.condiments : upper(condiment)
  ]
}
` + "```" + `

**Key Concepts:**
- Demonstrates **read-only data sources**
- Returns a list of available condiment strings
- No input parameters required
- Use ` + "`data.hw_condiments.all.condiments`" + ` to access the list

*Sauces and spreads wait,*
*Flavor enhancers ready,*
*Taste in every drop.*`,

		Attributes: map[string]schema.Attribute{
			"condiments": schema.ListAttribute{
				ElementType:         types.StringType,
				MarkdownDescription: "List of available condiments",
				Computed:            true,
			},
			"id": schema.StringAttribute{
				MarkdownDescription: "Data source identifier",
				Computed:            true,
			},
		},
	}
}

func (d *CondimentsDataSource) Configure(ctx context.Context, req datasource.ConfigureRequest, resp *datasource.ConfigureResponse) {
	// Prevent panic if the provider has not been configured.
	if req.ProviderData == nil {
		return
	}

	d.client = req.ProviderData
}

func (d *CondimentsDataSource) Read(ctx context.Context, req datasource.ReadRequest, resp *datasource.ReadResponse) {
	var data CondimentsDataSourceModel

	// Read Terraform configuration data into the model
	resp.Diagnostics.Append(req.Config.Get(ctx, &data)...)

	if resp.Diagnostics.HasError() {
		return
	}

	// Mock data - list of condiments
	condimentsList := []string{
		"mayonnaise",
		"mustard",
		"ketchup",
		"relish",
		"pickles",
		"onions",
		"lettuce",
		"tomato",
		"hot sauce",
		"ranch",
		"thousand island",
		"italian dressing",
		"oil and vinegar",
		"horseradish",
		"pesto",
		"hummus",
		"guacamole",
		"salsa",
		"chipotle mayo",
		"aioli",
		"tzatziki",
		"barbecue sauce",
	}

	// Convert to Terraform types
	condimentsValues := make([]attr.Value, len(condimentsList))
	for i, condiment := range condimentsList {
		condimentsValues[i] = types.StringValue(condiment)
	}

	condiments, diags := types.ListValue(types.StringType, condimentsValues)
	resp.Diagnostics.Append(diags...)
	if resp.Diagnostics.HasError() {
		return
	}

	data.Condiments = condiments
	data.Id = types.StringValue("condiments")

	tflog.Trace(ctx, "read condiments data source")

	// Save data into Terraform state
	resp.Diagnostics.Append(resp.State.Set(ctx, &data)...)
}

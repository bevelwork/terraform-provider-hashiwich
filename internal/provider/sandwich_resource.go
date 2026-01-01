package provider

import (
	"context"
	"fmt"
	"math/big"
	"strings"

	"github.com/hashicorp/terraform-plugin-framework/path"
	"github.com/hashicorp/terraform-plugin-framework/resource"
	"github.com/hashicorp/terraform-plugin-framework/resource/schema"
	"github.com/hashicorp/terraform-plugin-framework/resource/schema/planmodifier"
	"github.com/hashicorp/terraform-plugin-framework/resource/schema/stringplanmodifier"
	"github.com/hashicorp/terraform-plugin-framework/types"
	"github.com/hashicorp/terraform-plugin-log/tflog"
)

// Ensure provider defined types fully satisfy framework interfaces.
var _ resource.Resource = &SandwichResource{}
var _ resource.ResourceWithImportState = &SandwichResource{}

func NewSandwichResource() resource.Resource {
	return &SandwichResource{}
}

// SandwichResource defines the resource implementation.
type SandwichResource struct {
	client *ProviderConfig
}

// SandwichResourceModel describes the resource data model.
type SandwichResourceModel struct {
	Description types.String `tfsdk:"description"`
	BreadId     types.String `tfsdk:"bread_id"`
	MeatId      types.String `tfsdk:"meat_id"`
	Name        types.String `tfsdk:"name"`
	Price       types.Number `tfsdk:"price"`
	Id          types.String `tfsdk:"id"`
}

func (r *SandwichResource) Metadata(ctx context.Context, req resource.MetadataRequest, resp *resource.MetadataResponse) {
	resp.TypeName = req.ProviderTypeName + "_sandwich"
}

func (r *SandwichResource) Schema(ctx context.Context, req resource.SchemaRequest, resp *resource.SchemaResponse) {
	resp.Schema = schema.Schema{
		MarkdownDescription: `The ` + "`hw_sandwich`" + ` resource represents a complete sandwich that combines a bread resource and a meat resource.

This resource demonstrates **resource dependencies** in Terraform, as it requires existing ` + "`hw_bread`" + ` and ` + "`hw_meat`" + ` resources to be created first. The sandwich resource automatically computes its name based on the bread and meat types, and sets a fixed price.

**Example Usage:**

` + "```hcl" + `
# First, create the bread and meat resources
resource "hw_bread" "rye" {
  kind = "rye"
}

resource "hw_meat" "turkey" {
  kind = "turkey"
}

# Then create the sandwich using their IDs
resource "hw_sandwich" "turkey_on_rye" {
  bread_id = hw_bread.rye.id
  meat_id  = hw_meat.turkey.id
}
` + "```" + `

**Resource Dependencies:**
- This resource **depends on** ` + "`hw_bread`" + ` and ` + "`hw_meat`" + ` resources
- Terraform will automatically create bread and meat resources before creating the sandwich
- If bread_id or meat_id changes, the sandwich will be recreated with a new ID

**Computed Attributes:**
- ` + "`name`" + `: Automatically generated as "{meat} on {bread}" (e.g., "turkey on rye")
- ` + "`price`" + `: Fixed at $5.00 (plus any provider-level upcharge)
- ` + "`id`" + `: Automatically generated unique identifier

*Bread and meat unite,*
*Simple perfection in layers,*
*Lunchtime happiness.*`,

		Attributes: map[string]schema.Attribute{
			"description": schema.StringAttribute{
				MarkdownDescription: `Optional human-readable description of the sandwich resource.

This field is useful for documentation and can help identify the purpose or characteristics of the sandwich in your configuration.

**Example:**
` + "```hcl" + `
description = "Classic turkey on rye sandwich with premium ingredients"
` + "```" + `

**Best Practices:**
- Use descriptive text that helps understand the sandwich's purpose
- Can be used in outputs or documentation
- Does not affect resource behavior, name generation, or pricing`,
				Optional: true,
			},
			"bread_id": schema.StringAttribute{
				MarkdownDescription: `The unique identifier (ID) of an existing ` + "`hw_bread`" + ` resource to use for this sandwich.

**Type:** ` + "`string`" + ` (required)

**Example:**
` + "```hcl" + `
bread_id = hw_bread.rye.id
bread_id = "bread-rye-3"  # Direct ID reference (not recommended)
` + "```" + `

**Best Practices:**
- Always reference bread resources using ` + "`hw_bread.{resource_name}.id`" + ` syntax
- This creates an **implicit dependency** - Terraform will create the bread before the sandwich
- Avoid hardcoding IDs directly; use resource references instead

**Important Notes:**
- The bread resource must exist before this sandwich can be created
- Changing this value will cause the sandwich to be recreated (new ID and name generated)
- The bread kind is extracted from the ID to generate the sandwich name`,
				Required: true,
			},
			"meat_id": schema.StringAttribute{
				MarkdownDescription: `The unique identifier (ID) of an existing ` + "`hw_meat`" + ` resource to use for this sandwich.

**Type:** ` + "`string`" + ` (required)

**Example:**
` + "```hcl" + `
meat_id = hw_meat.turkey.id
meat_id = "meat-turkey-6"  # Direct ID reference (not recommended)
` + "```" + `

**Best Practices:**
- Always reference meat resources using ` + "`hw_meat.{resource_name}.id`" + ` syntax
- This creates an **implicit dependency** - Terraform will create the meat before the sandwich
- Avoid hardcoding IDs directly; use resource references instead

**Important Notes:**
- The meat resource must exist before this sandwich can be created
- Changing this value will cause the sandwich to be recreated (new ID and name generated)
- The meat kind is extracted from the ID to generate the sandwich name`,
				Required: true,
			},
			"name": schema.StringAttribute{
				Computed:            true,
				MarkdownDescription: `Automatically generated name of the sandwich in the format "{meat} on {bread}".

**Type:** ` + "`string`" + ` (computed, read-only)

**Format:** ` + "`{meat_kind} on {bread_kind}`" + `

**Example Values:**
- ` + "`turkey on rye`" + ` (for turkey meat on rye bread)
- ` + "`ham on sourdough`" + ` (for ham meat on sourdough bread)
- ` + "`roast beef on ciabatta`" + ` (for roast beef on ciabatta bread)

**How It Works:**
- The name is computed by extracting the kind from the ` + "`bread_id`" + ` and ` + "`meat_id`" + `
- The format is always "{meat} on {bread}" regardless of input order
- The name is stable and will not change unless bread_id or meat_id changes

**Important Notes:**
- This value is automatically computed and cannot be set manually
- Changing ` + "`bread_id`" + ` or ` + "`meat_id`" + ` will regenerate the name
- Use this in outputs to display human-readable sandwich names`,
				PlanModifiers: []planmodifier.String{
					stringplanmodifier.UseStateForUnknown(),
				},
			},
			"price": schema.NumberAttribute{
				Computed:            true,
				MarkdownDescription: `The price of the sandwich in dollars. This is a computed value that includes the base price plus any provider-level upcharge.

**Type:** ` + "`number`" + ` (computed, read-only)

**Base Price:** $5.00

**Pricing Logic:**
- Base price: $5.00 (fixed for all sandwiches)
- Provider upcharge: Added if ` + "`upcharge`" + ` is configured in the provider block
- Final price = $5.00 + upcharge amount

**Example Values:**
- Without upcharge: ` + "`5.00`" + `
- With upcharge of $0.50: ` + "`5.50`" + `
- With upcharge of $1.00: ` + "`6.00`" + `

**Important Notes:**
- This value is automatically computed and cannot be set manually
- The price is the same for all sandwiches regardless of bread or meat type
- Use this in outputs or calculations for total order costs`,
			},
			"id": schema.StringAttribute{
				Computed:            true,
				MarkdownDescription: `Automatically generated unique identifier for this sandwich resource.

**Type:** ` + "`string`" + ` (computed, read-only)

**Format:** ` + "`sandwich-{bread_id}-{meat_id}`" + `

**Example Values:**
- ` + "`sandwich-bread-rye-3-meat-turkey-6`" + `
- ` + "`sandwich-bread-sourdough-9-meat-ham-3`" + `

**Important Notes:**
- This value is automatically computed and cannot be set manually
- The ID is stable and will not change unless ` + "`bread_id`" + ` or ` + "`meat_id`" + ` changes
- Use this ID to reference the sandwich in other resources (e.g., ` + "`hw_bag.sandwiches`" + `)
- Changing either bread_id or meat_id will cause the resource to be recreated with a new ID`,
				PlanModifiers: []planmodifier.String{
					stringplanmodifier.UseStateForUnknown(),
				},
			},
		},
	}
}

func (r *SandwichResource) Configure(ctx context.Context, req resource.ConfigureRequest, resp *resource.ConfigureResponse) {
	// Prevent panic if the provider has not been configured.
	if req.ProviderData == nil {
		return
	}

	config, ok := req.ProviderData.(*ProviderConfig)
	if !ok {
		resp.Diagnostics.AddError(
			"Unexpected Provider Data Type",
			"Expected *ProviderConfig, got something else",
		)
		return
	}

	r.client = config
}

func (r *SandwichResource) Create(ctx context.Context, req resource.CreateRequest, resp *resource.CreateResponse) {
	var data SandwichResourceModel

	// Read Terraform plan data into the model
	resp.Diagnostics.Append(req.Plan.Get(ctx, &data)...)

	if resp.Diagnostics.HasError() {
		return
	}

	// Simulate API delay

	// Extract meat and bread kinds from their IDs
	meatKind := extractKindFromId(data.MeatId.ValueString(), "meat")
	breadKind := extractKindFromId(data.BreadId.ValueString(), "bread")

	// Generate name in format "{meat} on {bread}"
	name := fmt.Sprintf("%s on %s", meatKind, breadKind)
	data.Name = types.StringValue(name)

	// Set base price: $5.00, then apply upcharge
	basePrice := big.NewFloat(5.00)
	finalPrice := ApplyUpcharge(basePrice, r.client.Upcharge)
	data.Price = types.NumberValue(finalPrice)

	// Mock resource creation - generate a fake ID based on bread and meat IDs
	id := fmt.Sprintf("sandwich-%s-%s", data.BreadId.ValueString(), data.MeatId.ValueString())
	data.Id = types.StringValue(id)

	tflog.Trace(ctx, "created a sandwich resource", map[string]any{
		"id":       data.Id.ValueString(),
		"bread_id": data.BreadId.ValueString(),
		"meat_id":  data.MeatId.ValueString(),
	})

	// Save data into Terraform state
	resp.Diagnostics.Append(resp.State.Set(ctx, &data)...)
}

func (r *SandwichResource) Read(ctx context.Context, req resource.ReadRequest, resp *resource.ReadResponse) {
	var data SandwichResourceModel

	// Read Terraform prior state data into the model
	resp.Diagnostics.Append(req.State.Get(ctx, &data)...)

	if resp.Diagnostics.HasError() {
		return
	}

	// Simulate API delay

	// Regenerate name from IDs in case bread_id or meat_id changed externally
	meatKind := extractKindFromId(data.MeatId.ValueString(), "meat")
	breadKind := extractKindFromId(data.BreadId.ValueString(), "bread")
	name := fmt.Sprintf("%s on %s", meatKind, breadKind)
	data.Name = types.StringValue(name)

	// Ensure price is set (in case it wasn't in state)
	data.Price = types.NumberValue(big.NewFloat(5.00))

	// Mock resource read - just return the existing state
	// In a real implementation, this would fetch from an API

	// Save updated data into Terraform state
	resp.Diagnostics.Append(resp.State.Set(ctx, &data)...)
}

func (r *SandwichResource) Update(ctx context.Context, req resource.UpdateRequest, resp *resource.UpdateResponse) {
	var data SandwichResourceModel

	// Read Terraform plan data into the model
	resp.Diagnostics.Append(req.Plan.Get(ctx, &data)...)

	if resp.Diagnostics.HasError() {
		return
	}

	// Simulate API delay

	// Mock resource update - regenerate ID if bread_id or meat_id changed
	var state SandwichResourceModel
	resp.Diagnostics.Append(req.State.Get(ctx, &state)...)
	if resp.Diagnostics.HasError() {
		return
	}

	// If bread_id or meat_id changed, regenerate ID and name
	if !data.BreadId.Equal(state.BreadId) || !data.MeatId.Equal(state.MeatId) {
		// Extract meat and bread kinds from their IDs
		meatKind := extractKindFromId(data.MeatId.ValueString(), "meat")
		breadKind := extractKindFromId(data.BreadId.ValueString(), "bread")
		name := fmt.Sprintf("%s on %s", meatKind, breadKind)
		data.Name = types.StringValue(name)

		id := fmt.Sprintf("sandwich-%s-%s", data.BreadId.ValueString(), data.MeatId.ValueString())
		data.Id = types.StringValue(id)
	} else {
		// Keep existing ID and name
		data.Id = state.Id
		data.Name = state.Name
	}

	// Ensure price is always set to $5.00
	data.Price = types.NumberValue(big.NewFloat(5.00))

	// Save updated data into Terraform state
	resp.Diagnostics.Append(resp.State.Set(ctx, &data)...)
}

func (r *SandwichResource) Delete(ctx context.Context, req resource.DeleteRequest, resp *resource.DeleteResponse) {
	var data SandwichResourceModel

	// Read Terraform prior state data into the model
	resp.Diagnostics.Append(req.State.Get(ctx, &data)...)

	if resp.Diagnostics.HasError() {
		return
	}

	// Simulate API delay

	// Mock resource deletion - nothing to do
	tflog.Trace(ctx, "deleted a sandwich resource", map[string]any{
		"id": data.Id.ValueString(),
	})
}

func (r *SandwichResource) ImportState(ctx context.Context, req resource.ImportStateRequest, resp *resource.ImportStateResponse) {
	resource.ImportStatePassthroughID(ctx, path.Root("id"), req, resp)
}

// extractKindFromId extracts the kind from a resource ID
// IDs are in format "{type}-{kind}-{length}" where kind may contain dashes
// Example: "bread-rye-3" or "meat-roast-beef-10"
func extractKindFromId(id, prefix string) string {
	// Remove the prefix (e.g., "bread-" or "meat-")
	if !strings.HasPrefix(id, prefix+"-") {
		return "unknown"
	}
	
	// Remove prefix and get the rest
	rest := strings.TrimPrefix(id, prefix+"-")
	
	// Find the last dash (which separates kind from length)
	lastDash := strings.LastIndex(rest, "-")
	if lastDash == -1 {
		return rest
	}
	
	// Return everything before the last dash (the kind)
	return rest[:lastDash]
}

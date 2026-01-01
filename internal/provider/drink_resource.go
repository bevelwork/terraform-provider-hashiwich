package provider

import (
	"context"
	"fmt"
	"math/big"

	"github.com/hashicorp/terraform-plugin-framework/path"
	"github.com/hashicorp/terraform-plugin-framework/resource"
	"github.com/hashicorp/terraform-plugin-framework/resource/schema"
	"github.com/hashicorp/terraform-plugin-framework/resource/schema/planmodifier"
	"github.com/hashicorp/terraform-plugin-framework/resource/schema/stringplanmodifier"
	"github.com/hashicorp/terraform-plugin-framework/types"
	"github.com/hashicorp/terraform-plugin-log/tflog"
)

// Ensure provider defined types fully satisfy framework interfaces.
var _ resource.Resource = &DrinkResource{}
var _ resource.ResourceWithImportState = &DrinkResource{}

func NewDrinkResource() resource.Resource {
	return &DrinkResource{}
}

// DrinkResource defines the resource implementation.
type DrinkResource struct {
	client *ProviderConfig
}

// IceModel describes the ice block data model.
type IceModel struct {
	Some types.Bool `tfsdk:"some"`
	Lots types.Bool `tfsdk:"lots"`
	Max  types.Bool `tfsdk:"max"`
}

// DrinkResourceModel describes the resource data model.
type DrinkResourceModel struct {
	Description types.String `tfsdk:"description"`
	Kind        types.String `tfsdk:"kind"`
	Ice         types.List   `tfsdk:"ice"`
	Price       types.Number `tfsdk:"price"`
	Id          types.String `tfsdk:"id"`
}

func (r *DrinkResource) Metadata(ctx context.Context, req resource.MetadataRequest, resp *resource.MetadataResponse) {
	resp.TypeName = req.ProviderTypeName + "_drink"
}

func (r *DrinkResource) Schema(ctx context.Context, req resource.SchemaRequest, resp *resource.SchemaResponse) {
	resp.Schema = schema.Schema{
		MarkdownDescription: `The ` + "`hw_drink`" + ` resource represents a beverage available in the sandwich shop.

This resource demonstrates **nested blocks** in Terraform through the optional ` + "`ice`" + ` block, which allows configuring ice preferences. The ice block is a list that can contain multiple ice configuration objects, making it ideal for learning about ` + "`dynamic`" + ` blocks.

**Example Usage:**

` + "```hcl" + `
# Simple drink without ice configuration
resource "hw_drink" "cola" {
  kind        = "cola"
  description = "Classic cola"
}

# Drink with ice configuration using nested blocks
resource "hw_drink" "soda_with_ice" {
  kind        = "soda"
  description = "Soda with ice"
  
  ice {
    some = true
  }
}

# Multiple ice blocks (demonstrates list blocks)
resource "hw_drink" "soda_multiple_ice" {
  kind = "soda"
  
  ice {
    some = true
  }
  
  ice {
    lots = true
  }
}
` + "```" + `

**Common Drink Types:**
- ` + "`cola`" + `, ` + "`soda`" + `, ` + "`juice`" + `, ` + "`water`" + `, ` + "`lemonade`" + `

**Learning Concepts:**
- **Nested Blocks**: The ` + "`ice`" + ` block demonstrates how to use nested configuration blocks
- **Dynamic Blocks**: Use ` + "`dynamic`" + ` blocks to conditionally create ice configurations
- **List Blocks**: The ice block is a list, allowing multiple ice configurations

*Cool liquid refreshment,*
*Ice cubes clinking in the glass,*
*Quenching every thirst.*`,

		Attributes: map[string]schema.Attribute{
			"description": schema.StringAttribute{
				MarkdownDescription: `Optional human-readable description of the drink resource.

**Type:** ` + "`string`" + ` (optional)

**Example:**
` + "```hcl" + `
description = "Refreshing cola beverage"
` + "```" + `

**Best Practices:**
- Use descriptive text that helps understand the drink's purpose
- Can be used in outputs or documentation
- Does not affect resource behavior or pricing`,
				Optional: true,
			},
			"kind": schema.StringAttribute{
				MarkdownDescription: `The type or variety of beverage. This is a required field that identifies what kind of drink this resource represents.

**Type:** ` + "`string`" + ` (required)

**Examples:**
` + "```hcl" + `
kind = "cola"
kind = "soda"
kind = "juice"
kind = "water"
` + "```" + `

**Common Values:**
- ` + "`cola`" + `, ` + "`soda`" + `, ` + "`juice`" + `, ` + "`water`" + `, ` + "`lemonade`" + `, ` + "`iced tea`" + `

**Important Notes:**
- This value is used to generate the resource ID
- Changing this value will cause the resource to be recreated (new ID generated)
- The value is case-sensitive
- Any string value is accepted`,
				Required: true,
			},
			"price": schema.NumberAttribute{
				Computed:            true,
				MarkdownDescription: `The price of the drink in dollars. This is a computed value that includes the base price plus any provider-level upcharge.

**Type:** ` + "`number`" + ` (computed, read-only)

**Base Price:** $1.00

**Pricing Logic:**
- Base price: $1.00 (fixed for all drinks)
- Provider upcharge: Added if ` + "`upcharge`" + ` is configured in the provider block
- Final price = $1.00 + upcharge amount

**Example Values:**
- Without upcharge: ` + "`1.00`" + `
- With upcharge of $0.50: ` + "`1.50`" + `

**Important Notes:**
- This value is automatically computed and cannot be set manually
- The price is the same for all drinks regardless of kind or ice configuration
- Use this in outputs or calculations for total order costs`,
			},
			"id": schema.StringAttribute{
				Computed:            true,
				MarkdownDescription: `Automatically generated unique identifier for this drink resource.

**Type:** ` + "`string`" + ` (computed, read-only)

**Format:** ` + "`drink-{kind}-{length}`" + `

**Example Values:**
- ` + "`drink-cola-4`" + ` (for kind = "cola")
- ` + "`drink-soda-4`" + ` (for kind = "soda")

**Important Notes:**
- This value is automatically computed and cannot be set manually
- The ID is stable and will not change unless the ` + "`kind`" + ` attribute changes
- Use this ID to reference the drink in other resources or outputs`,
				PlanModifiers: []planmodifier.String{
					stringplanmodifier.UseStateForUnknown(),
				},
			},
		},
		Blocks: map[string]schema.Block{
			"ice": schema.ListNestedBlock{
				NestedObject: schema.NestedBlockObject{
					Attributes: map[string]schema.Attribute{
						"some": schema.BoolAttribute{
							MarkdownDescription: `Set to ` + "`true`" + ` to request some ice in the drink.

**Type:** ` + "`bool`" + ` (optional)

**Example:**
` + "```hcl" + `
ice {
  some = true
}
` + "```" + `

**Note:** Only one of ` + "`some`" + `, ` + "`lots`" + `, or ` + "`max`" + ` should be set to ` + "`true`" + `, though the provider does not enforce this.`,
							Optional: true,
						},
						"lots": schema.BoolAttribute{
							MarkdownDescription: `Set to ` + "`true`" + ` to request lots of ice in the drink.

**Type:** ` + "`bool`" + ` (optional)

**Example:**
` + "```hcl" + `
ice {
  lots = true
}
` + "```" + `

**Note:** Only one of ` + "`some`" + `, ` + "`lots`" + `, or ` + "`max`" + ` should be set to ` + "`true`" + `, though the provider does not enforce this.`,
							Optional: true,
						},
						"max": schema.BoolAttribute{
							MarkdownDescription: `Set to ` + "`true`" + ` to request maximum ice in the drink.

**Type:** ` + "`bool`" + ` (optional)

**Example:**
` + "```hcl" + `
ice {
  max = true
}
` + "```" + `

**Note:** Only one of ` + "`some`" + `, ` + "`lots`" + `, or ` + "`max`" + ` should be set to ` + "`true`" + `, though the provider does not enforce this.`,
							Optional: true,
						},
					},
				},
				MarkdownDescription: `Optional nested block for configuring ice preferences. This is a **list block**, meaning you can specify multiple ` + "`ice`" + ` blocks.

**Type:** ` + "`list(object)`" + ` (optional)

**Learning Purpose:**
This block demonstrates several Terraform concepts:
- **Nested Blocks**: How to structure complex configuration
- **List Blocks**: Multiple blocks of the same type
- **Dynamic Blocks**: Use ` + "`dynamic \"ice\"`" + ` to conditionally create ice configurations

**Example Usage:**

` + "```hcl" + `
# Single ice block
ice {
  some = true
}

# Multiple ice blocks (list)
ice {
  some = true
}
ice {
  lots = true
}

# Using dynamic blocks
dynamic "ice" {
  for_each = var.include_ice ? [1] : []
  content {
    some = true
  }
}
` + "```" + `

**Block Attributes:**
- ` + "`some`" + ` (bool, optional): Request some ice
- ` + "`lots`" + ` (bool, optional): Request lots of ice
- ` + "`max`" + ` (bool, optional): Request maximum ice

**Best Practices:**
- Use ` + "`dynamic`" + ` blocks when ice configuration is conditional
- Only set one of the boolean attributes to ` + "`true`" + ` per block
- This block is optional - drinks can be created without ice configuration`,
			},
		},
	}
}

func (r *DrinkResource) Configure(ctx context.Context, req resource.ConfigureRequest, resp *resource.ConfigureResponse) {
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

func (r *DrinkResource) Create(ctx context.Context, req resource.CreateRequest, resp *resource.CreateResponse) {
	var data DrinkResourceModel

	// Read Terraform plan data into the model
	resp.Diagnostics.Append(req.Plan.Get(ctx, &data)...)

	if resp.Diagnostics.HasError() {
		return
	}

	// Validate ice configuration if provided
	if !data.Ice.IsNull() && !data.Ice.IsUnknown() {
		var iceList []IceModel
		resp.Diagnostics.Append(data.Ice.ElementsAs(ctx, &iceList, false)...)
		if resp.Diagnostics.HasError() {
			return
		}

		// Should have exactly one ice block
		if len(iceList) != 1 {
			resp.Diagnostics.AddError(
				"Invalid Ice Configuration",
				fmt.Sprintf("Exactly one ice block must be provided. Found %d blocks.", len(iceList)),
			)
			return
		}

		ice := iceList[0]
		// Count how many ice options are true
		trueCount := 0
		if !ice.Some.IsNull() && ice.Some.ValueBool() {
			trueCount++
		}
		if !ice.Lots.IsNull() && ice.Lots.ValueBool() {
			trueCount++
		}
		if !ice.Max.IsNull() && ice.Max.ValueBool() {
			trueCount++
		}

		if trueCount != 1 {
			resp.Diagnostics.AddError(
				"Invalid Ice Configuration",
				fmt.Sprintf("Exactly one of 'some', 'lots', or 'max' must be true in the ice block. Found %d true values.", trueCount),
			)
			return
		}
	}

	// Simulate API delay

	// Set base price: $1.00, then apply upcharge
	basePrice := big.NewFloat(1.00)
	finalPrice := ApplyUpcharge(basePrice, r.client.Upcharge)
	data.Price = types.NumberValue(finalPrice)

	// Mock resource creation - generate a fake ID based on the kind
	id := fmt.Sprintf("drink-%s-%d", data.Kind.ValueString(), len(data.Kind.ValueString()))
	data.Id = types.StringValue(id)

	tflog.Trace(ctx, "created a drink resource", map[string]any{
		"id":   data.Id.ValueString(),
		"kind": data.Kind.ValueString(),
	})

	// Save data into Terraform state
	resp.Diagnostics.Append(resp.State.Set(ctx, &data)...)
}

func (r *DrinkResource) Read(ctx context.Context, req resource.ReadRequest, resp *resource.ReadResponse) {
	var data DrinkResourceModel

	// Read Terraform prior state data into the model
	resp.Diagnostics.Append(req.State.Get(ctx, &data)...)

	if resp.Diagnostics.HasError() {
		return
	}

	// Simulate API delay

	// Ensure price is set (in case it wasn't in state)
	data.Price = types.NumberValue(big.NewFloat(1.00))

	// Mock resource read - just return the existing state
	// In a real implementation, this would fetch from an API

	// Save updated data into Terraform state
	resp.Diagnostics.Append(resp.State.Set(ctx, &data)...)
}

func (r *DrinkResource) Update(ctx context.Context, req resource.UpdateRequest, resp *resource.UpdateResponse) {
	var data DrinkResourceModel

	// Read Terraform plan data into the model
	resp.Diagnostics.Append(req.Plan.Get(ctx, &data)...)

	if resp.Diagnostics.HasError() {
		return
	}

	// Validate ice configuration if provided
	if !data.Ice.IsNull() && !data.Ice.IsUnknown() {
		var iceList []IceModel
		resp.Diagnostics.Append(data.Ice.ElementsAs(ctx, &iceList, false)...)
		if resp.Diagnostics.HasError() {
			return
		}

		// Should have exactly one ice block
		if len(iceList) != 1 {
			resp.Diagnostics.AddError(
				"Invalid Ice Configuration",
				fmt.Sprintf("Exactly one ice block must be provided. Found %d blocks.", len(iceList)),
			)
			return
		}

		ice := iceList[0]
		// Count how many ice options are true
		trueCount := 0
		if !ice.Some.IsNull() && ice.Some.ValueBool() {
			trueCount++
		}
		if !ice.Lots.IsNull() && ice.Lots.ValueBool() {
			trueCount++
		}
		if !ice.Max.IsNull() && ice.Max.ValueBool() {
			trueCount++
		}

		if trueCount != 1 {
			resp.Diagnostics.AddError(
				"Invalid Ice Configuration",
				fmt.Sprintf("Exactly one of 'some', 'lots', or 'max' must be true in the ice block. Found %d true values.", trueCount),
			)
			return
		}
	}

	// Simulate API delay

	// Mock resource update - regenerate ID if kind changed
	var state DrinkResourceModel
	resp.Diagnostics.Append(req.State.Get(ctx, &state)...)
	if resp.Diagnostics.HasError() {
		return
	}

	// If kind changed, regenerate ID
	if !data.Kind.Equal(state.Kind) {
		id := fmt.Sprintf("drink-%s-%d", data.Kind.ValueString(), len(data.Kind.ValueString()))
		data.Id = types.StringValue(id)
	} else {
		// Keep existing ID
		data.Id = state.Id
	}

	// Ensure price is always set to $1.00
	data.Price = types.NumberValue(big.NewFloat(1.00))

	// Save updated data into Terraform state
	resp.Diagnostics.Append(resp.State.Set(ctx, &data)...)
}

func (r *DrinkResource) Delete(ctx context.Context, req resource.DeleteRequest, resp *resource.DeleteResponse) {
	var data DrinkResourceModel

	// Read Terraform prior state data into the model
	resp.Diagnostics.Append(req.State.Get(ctx, &data)...)

	if resp.Diagnostics.HasError() {
		return
	}

	// Simulate API delay

	// Mock resource deletion - nothing to do
	tflog.Trace(ctx, "deleted a drink resource", map[string]any{
		"id": data.Id.ValueString(),
	})
}

func (r *DrinkResource) ImportState(ctx context.Context, req resource.ImportStateRequest, resp *resource.ImportStateResponse) {
	resource.ImportStatePassthroughID(ctx, path.Root("id"), req, resp)
}

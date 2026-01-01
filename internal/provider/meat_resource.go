package provider

import (
	"context"
	"fmt"
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
var _ resource.Resource = &MeatResource{}
var _ resource.ResourceWithImportState = &MeatResource{}

func NewMeatResource() resource.Resource {
	return &MeatResource{}
}

// MeatResource defines the resource implementation.
type MeatResource struct {
	client any
}

// MeatResourceModel describes the resource data model.
type MeatResourceModel struct {
	Description types.String `tfsdk:"description"`
	Kind        types.String `tfsdk:"kind"`
	Id          types.String `tfsdk:"id"`
}

func (r *MeatResource) Metadata(ctx context.Context, req resource.MetadataRequest, resp *resource.MetadataResponse) {
	resp.TypeName = req.ProviderTypeName + "_meat"
}

func (r *MeatResource) Schema(ctx context.Context, req resource.SchemaRequest, resp *resource.SchemaResponse) {
	resp.Schema = schema.Schema{
		MarkdownDescription: `The ` + "`hw_meat`" + ` resource represents a type of deli meat available in the sandwich shop.

This resource is used to create meat instances that can then be referenced by other resources like ` + "`hw_sandwich`" + `. Each meat resource has a unique identifier (ID) that is automatically generated based on the meat kind.

**Example Usage:**

` + "```hcl" + `
resource "hw_meat" "turkey" {
  kind        = "turkey"
  description = "Premium sliced turkey"
}

resource "hw_meat" "ham" {
  kind        = "ham"
  description = "Honey-glazed ham"
}

resource "hw_meat" "roast_beef" {
  kind        = "roast beef"
  description = "Slow-roasted beef"
}
` + "```" + `

**Common Meat Types:**
- ` + "`turkey`" + ` - Sliced turkey breast
- ` + "`ham`" + ` - Deli ham
- ` + "`roast beef`" + ` - Roast beef
- ` + "`chicken`" + ` - Grilled chicken
- ` + "`pastrami`" + ` - Spiced pastrami
- ` + "`salami`" + ` - Italian salami

**Note:** The ` + "`kind`" + ` attribute accepts any string value, including multi-word names (e.g., "roast beef"). The resource ID is automatically computed and cannot be set manually.`,

		Attributes: map[string]schema.Attribute{
			"description": schema.StringAttribute{
				MarkdownDescription: `Optional human-readable description of the meat resource.

This field is useful for documentation and can help identify the characteristics or quality of the meat in your configuration.

**Example:**
` + "```hcl" + `
description = "Premium organic turkey, sliced thin"
` + "```" + `

**Best Practices:**
- Use descriptive text that helps understand the meat's characteristics
- Can be used in outputs or documentation
- Does not affect resource behavior or ID generation`,
				Optional: true,
			},
			"kind": schema.StringAttribute{
				MarkdownDescription: `The type or variety of deli meat. This is a required field that identifies what kind of meat this resource represents.

**Type:** ` + "`string`" + ` (required)

**Examples:**
` + "```hcl" + `
kind = "turkey"
kind = "ham"
kind = "roast beef"  # Multi-word values are supported
` + "```" + `

**Common Values:**
- ` + "`turkey`" + `, ` + "`ham`" + `, ` + "`roast beef`" + `, ` + "`chicken`" + `, ` + "`pastrami`" + `, ` + "`salami`" + `

**Important Notes:**
- This value is used to generate the resource ID
- Changing this value will cause the resource to be recreated (new ID generated)
- The value is case-sensitive
- Multi-word values (e.g., "roast beef") are supported
- Any string value is accepted, but using standard meat types improves readability`,
				Required: true,
			},
			"id": schema.StringAttribute{
				Computed:            true,
				MarkdownDescription: `Automatically generated unique identifier for this meat resource.

**Type:** ` + "`string`" + ` (computed, read-only)

**Format:** ` + "`meat-{kind}-{length}`" + `

**Example Values:**
- ` + "`meat-turkey-6`" + ` (for kind = "turkey")
- ` + "`meat-roast-beef-10`" + ` (for kind = "roast beef")

**Important Notes:**
- This value is automatically computed and cannot be set manually
- The ID is stable and will not change unless the ` + "`kind`" + ` attribute changes
- Use this ID to reference the meat in other resources (e.g., ` + "`hw_sandwich.meat_id`" + `)
- The ID format includes the meat kind and the length of the kind string
- Multi-word kinds will have spaces converted to dashes in the ID`,
				PlanModifiers: []planmodifier.String{
					stringplanmodifier.UseStateForUnknown(),
				},
			},
		},
	}
}

func (r *MeatResource) Configure(ctx context.Context, req resource.ConfigureRequest, resp *resource.ConfigureResponse) {
	// Prevent panic if the provider has not been configured.
	if req.ProviderData == nil {
		return
	}

	r.client = req.ProviderData
}

func (r *MeatResource) Create(ctx context.Context, req resource.CreateRequest, resp *resource.CreateResponse) {
	var data MeatResourceModel

	// Read Terraform plan data into the model
	resp.Diagnostics.Append(req.Plan.Get(ctx, &data)...)

	if resp.Diagnostics.HasError() {
		return
	}

	// Simulate API delay

	// Mock resource creation - generate a fake ID based on the kind
	id := fmt.Sprintf("meat-%s-%d", data.Kind.ValueString(), len(data.Kind.ValueString()))
	data.Id = types.StringValue(id)

	tflog.Trace(ctx, "created a meat resource", map[string]any{
		"id":   data.Id.ValueString(),
		"kind": data.Kind.ValueString(),
	})

	// Save data into Terraform state
	resp.Diagnostics.Append(resp.State.Set(ctx, &data)...)
}

func (r *MeatResource) Read(ctx context.Context, req resource.ReadRequest, resp *resource.ReadResponse) {
	var data MeatResourceModel

	// Read Terraform prior state data into the model
	resp.Diagnostics.Append(req.State.Get(ctx, &data)...)

	if resp.Diagnostics.HasError() {
		return
	}

	// Simulate API delay

	// Mock resource read - just return the existing state
	// In a real implementation, this would fetch from an API

	// Save updated data into Terraform state
	resp.Diagnostics.Append(resp.State.Set(ctx, &data)...)
}

func (r *MeatResource) Update(ctx context.Context, req resource.UpdateRequest, resp *resource.UpdateResponse) {
	var data MeatResourceModel

	// Read Terraform plan data into the model
	resp.Diagnostics.Append(req.Plan.Get(ctx, &data)...)

	if resp.Diagnostics.HasError() {
		return
	}

	// Simulate API delay

	// Mock resource update - regenerate ID if kind changed
	var state MeatResourceModel
	resp.Diagnostics.Append(req.State.Get(ctx, &state)...)
	if resp.Diagnostics.HasError() {
		return
	}

	// If kind changed, regenerate ID
	if !data.Kind.Equal(state.Kind) {
		id := fmt.Sprintf("meat-%s-%d", data.Kind.ValueString(), len(data.Kind.ValueString()))
		data.Id = types.StringValue(id)
	} else {
		// Keep existing ID
		data.Id = state.Id
	}

	// Save updated data into Terraform state
	resp.Diagnostics.Append(resp.State.Set(ctx, &data)...)
}

func (r *MeatResource) Delete(ctx context.Context, req resource.DeleteRequest, resp *resource.DeleteResponse) {
	var data MeatResourceModel

	// Read Terraform prior state data into the model
	resp.Diagnostics.Append(req.State.Get(ctx, &data)...)

	if resp.Diagnostics.HasError() {
		return
	}

	// Simulate API delay

	// Mock resource deletion - nothing to do
	tflog.Trace(ctx, "deleted a meat resource", map[string]any{
		"id": data.Id.ValueString(),
	})
}

func (r *MeatResource) ImportState(ctx context.Context, req resource.ImportStateRequest, resp *resource.ImportStateResponse) {
	resource.ImportStatePassthroughID(ctx, path.Root("id"), req, resp)
}

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
var _ resource.Resource = &BreadResource{}
var _ resource.ResourceWithImportState = &BreadResource{}

func NewBreadResource() resource.Resource {
	return &BreadResource{}
}

// BreadResource defines the resource implementation.
type BreadResource struct {
	client any
}

// BreadResourceModel describes the resource data model.
type BreadResourceModel struct {
	Description types.String `tfsdk:"description"`
	Kind        types.String `tfsdk:"kind"`
	Id          types.String `tfsdk:"id"`
}

func (r *BreadResource) Metadata(ctx context.Context, req resource.MetadataRequest, resp *resource.MetadataResponse) {
	resp.TypeName = req.ProviderTypeName + "_bread"
}

func (r *BreadResource) Schema(ctx context.Context, req resource.SchemaRequest, resp *resource.SchemaResponse) {
	resp.Schema = schema.Schema{
		MarkdownDescription: `The ` + "`hw_bread`" + ` resource represents a type of bread available in the sandwich shop.

This resource is used to create bread instances that can then be referenced by other resources like ` + "`hw_sandwich`" + `. Each bread resource has a unique identifier (ID) that is automatically generated based on the bread kind.

**Example Usage:**

` + "```hcl" + `
resource "hw_bread" "rye" {
  kind        = "rye"
  description = "Fresh rye bread"
}

resource "hw_bread" "sourdough" {
  kind        = "sourdough"
  description = "Artisan sourdough bread"
}
` + "```" + `

**Common Bread Types:**
- ` + "`rye`" + ` - Classic rye bread
- ` + "`sourdough`" + ` - Tangy sourdough bread
- ` + "`wheat`" + ` - Whole wheat bread
- ` + "`ciabatta`" + ` - Italian ciabatta bread
- ` + "`white`" + ` - White bread
- ` + "`multigrain`" + ` - Multigrain bread

**Note:** The ` + "`kind`" + ` attribute accepts any string value, but using common bread types makes your configuration more readable. The resource ID is automatically computed and cannot be set manually.`,

		Attributes: map[string]schema.Attribute{
			"description": schema.StringAttribute{
				MarkdownDescription: `Optional human-readable description of the bread resource.

This field is useful for documentation and can help identify the purpose or characteristics of the bread in your configuration.

**Example:**
` + "```hcl" + `
description = "Fresh-baked daily rye bread with caraway seeds"
` + "```" + `

**Best Practices:**
- Use descriptive text that helps understand the bread's purpose
- Can be used in outputs or documentation
- Does not affect resource behavior or ID generation`,
				Optional: true,
			},
			"kind": schema.StringAttribute{
				MarkdownDescription: `The type or variety of bread. This is a required field that identifies what kind of bread this resource represents.

**Type:** ` + "`string`" + ` (required)

**Examples:**
` + "```hcl" + `
kind = "rye"
kind = "sourdough"
kind = "whole wheat"
` + "```" + `

**Common Values:**
- ` + "`rye`" + `, ` + "`sourdough`" + `, ` + "`wheat`" + `, ` + "`ciabatta`" + `, ` + "`white`" + `, ` + "`multigrain`" + `

**Important Notes:**
- This value is used to generate the resource ID
- Changing this value will cause the resource to be recreated (new ID generated)
- The value is case-sensitive
- Any string value is accepted, but using standard bread types improves readability`,
				Required: true,
			},
			"id": schema.StringAttribute{
				Computed:            true,
				MarkdownDescription: `Automatically generated unique identifier for this bread resource.

**Type:** ` + "`string`" + ` (computed, read-only)

**Format:** ` + "`bread-{kind}-{length}`" + `

**Example Values:**
- ` + "`bread-rye-3`" + ` (for kind = "rye")
- ` + "`bread-sourdough-9`" + ` (for kind = "sourdough")

**Important Notes:**
- This value is automatically computed and cannot be set manually
- The ID is stable and will not change unless the ` + "`kind`" + ` attribute changes
- Use this ID to reference the bread in other resources (e.g., ` + "`hw_sandwich.bread_id`" + `)
- The ID format includes the bread kind and the length of the kind string`,
				PlanModifiers: []planmodifier.String{
					stringplanmodifier.UseStateForUnknown(),
				},
			},
		},
	}
}

func (r *BreadResource) Configure(ctx context.Context, req resource.ConfigureRequest, resp *resource.ConfigureResponse) {
	// Prevent panic if the provider has not been configured.
	if req.ProviderData == nil {
		return
	}

	r.client = req.ProviderData
}

func (r *BreadResource) Create(ctx context.Context, req resource.CreateRequest, resp *resource.CreateResponse) {
	var data BreadResourceModel

	// Read Terraform plan data into the model
	resp.Diagnostics.Append(req.Plan.Get(ctx, &data)...)

	if resp.Diagnostics.HasError() {
		return
	}

	// Simulate API delay

	// Mock resource creation - generate a fake ID based on the kind
	id := fmt.Sprintf("bread-%s-%d", data.Kind.ValueString(), len(data.Kind.ValueString()))
	data.Id = types.StringValue(id)

	tflog.Trace(ctx, "created a bread resource", map[string]any{
		"id":   data.Id.ValueString(),
		"kind": data.Kind.ValueString(),
	})

	// Save data into Terraform state
	resp.Diagnostics.Append(resp.State.Set(ctx, &data)...)
}

func (r *BreadResource) Read(ctx context.Context, req resource.ReadRequest, resp *resource.ReadResponse) {
	var data BreadResourceModel

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

func (r *BreadResource) Update(ctx context.Context, req resource.UpdateRequest, resp *resource.UpdateResponse) {
	var data BreadResourceModel

	// Read Terraform plan data into the model
	resp.Diagnostics.Append(req.Plan.Get(ctx, &data)...)

	if resp.Diagnostics.HasError() {
		return
	}

	// Simulate API delay

	// Mock resource update - regenerate ID if kind changed
	var state BreadResourceModel
	resp.Diagnostics.Append(req.State.Get(ctx, &state)...)
	if resp.Diagnostics.HasError() {
		return
	}

	// If kind changed, regenerate ID
	if !data.Kind.Equal(state.Kind) {
		id := fmt.Sprintf("bread-%s-%d", data.Kind.ValueString(), len(data.Kind.ValueString()))
		data.Id = types.StringValue(id)
	} else {
		// Keep existing ID
		data.Id = state.Id
	}

	// Save updated data into Terraform state
	resp.Diagnostics.Append(resp.State.Set(ctx, &data)...)
}

func (r *BreadResource) Delete(ctx context.Context, req resource.DeleteRequest, resp *resource.DeleteResponse) {
	var data BreadResourceModel

	// Read Terraform prior state data into the model
	resp.Diagnostics.Append(req.State.Get(ctx, &data)...)

	if resp.Diagnostics.HasError() {
		return
	}

	// Simulate API delay

	// Mock resource deletion - nothing to do
	tflog.Trace(ctx, "deleted a bread resource", map[string]any{
		"id": data.Id.ValueString(),
	})
}

func (r *BreadResource) ImportState(ctx context.Context, req resource.ImportStateRequest, resp *resource.ImportStateResponse) {
	resource.ImportStatePassthroughID(ctx, path.Root("id"), req, resp)
}

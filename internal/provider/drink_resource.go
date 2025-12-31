package provider

import (
	"context"
	"fmt"
	"time"

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
	client any
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
	Ice         types.List    `tfsdk:"ice"`
	Id          types.String `tfsdk:"id"`
}

func (r *DrinkResource) Metadata(ctx context.Context, req resource.MetadataRequest, resp *resource.MetadataResponse) {
	resp.TypeName = req.ProviderTypeName + "_drink"
}

func (r *DrinkResource) Schema(ctx context.Context, req resource.SchemaRequest, resp *resource.SchemaResponse) {
	resp.Schema = schema.Schema{
		MarkdownDescription: "Mock drink resource for instructional purposes",

		Attributes: map[string]schema.Attribute{
			"description": schema.StringAttribute{
				MarkdownDescription: "A description of the drink resource",
				Optional:            true,
			},
			"kind": schema.StringAttribute{
				MarkdownDescription: "The kind of pop/soda",
				Required:            true,
			},
			"id": schema.StringAttribute{
				Computed:            true,
				MarkdownDescription: "Drink identifier",
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
							MarkdownDescription: "Some ice",
							Optional:            true,
						},
						"lots": schema.BoolAttribute{
							MarkdownDescription: "Lots of ice",
							Optional:            true,
						},
						"max": schema.BoolAttribute{
							MarkdownDescription: "Maximum ice",
							Optional:            true,
						},
					},
				},
				MarkdownDescription: "Ice configuration block. Only one of some, lots, or max should be true. Use dynamic blocks to conditionally set values.",
			},
		},
	}
}

func (r *DrinkResource) Configure(ctx context.Context, req resource.ConfigureRequest, resp *resource.ConfigureResponse) {
	// Prevent panic if the provider has not been configured.
	if req.ProviderData == nil {
		return
	}

	r.client = req.ProviderData
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
	time.Sleep(300 * time.Millisecond)

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
	time.Sleep(300 * time.Millisecond)

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
	time.Sleep(300 * time.Millisecond)

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
	time.Sleep(300 * time.Millisecond)

	// Mock resource deletion - nothing to do
	tflog.Trace(ctx, "deleted a drink resource", map[string]any{
		"id": data.Id.ValueString(),
	})
}

func (r *DrinkResource) ImportState(ctx context.Context, req resource.ImportStateRequest, resp *resource.ImportStateResponse) {
	resource.ImportStatePassthroughID(ctx, path.Root("id"), req, resp)
}

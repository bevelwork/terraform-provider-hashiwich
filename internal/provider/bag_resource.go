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
var _ resource.Resource = &BagResource{}
var _ resource.ResourceWithImportState = &BagResource{}

func NewBagResource() resource.Resource {
	return &BagResource{}
}

// BagResource defines the resource implementation.
type BagResource struct {
	client any
}

// BagResourceModel describes the resource data model.
type BagResourceModel struct {
	Description types.String `tfsdk:"description"`
	SandwichIds types.List   `tfsdk:"sandwich_ids"`
	Id          types.String `tfsdk:"id"`
}

func (r *BagResource) Metadata(ctx context.Context, req resource.MetadataRequest, resp *resource.MetadataResponse) {
	resp.TypeName = req.ProviderTypeName + "_bag"
}

func (r *BagResource) Schema(ctx context.Context, req resource.SchemaRequest, resp *resource.SchemaResponse) {
	resp.Schema = schema.Schema{
		MarkdownDescription: "Mock bag resource for instructional purposes. Can contain multiple sandwiches.",

		Attributes: map[string]schema.Attribute{
			"description": schema.StringAttribute{
				MarkdownDescription: "A description of the bag resource",
				Optional:            true,
			},
			"sandwich_ids": schema.ListAttribute{
				ElementType:         types.StringType,
				MarkdownDescription: "List of sandwich resource IDs to include in the bag",
				Required:            true,
			},
			"id": schema.StringAttribute{
				Computed:            true,
				MarkdownDescription: "Bag identifier",
				PlanModifiers: []planmodifier.String{
					stringplanmodifier.UseStateForUnknown(),
				},
			},
		},
	}
}

func (r *BagResource) Configure(ctx context.Context, req resource.ConfigureRequest, resp *resource.ConfigureResponse) {
	// Prevent panic if the provider has not been configured.
	if req.ProviderData == nil {
		return
	}

	r.client = req.ProviderData
}

func (r *BagResource) Create(ctx context.Context, req resource.CreateRequest, resp *resource.CreateResponse) {
	var data BagResourceModel

	// Read Terraform plan data into the model
	resp.Diagnostics.Append(req.Plan.Get(ctx, &data)...)

	if resp.Diagnostics.HasError() {
		return
	}

	// Simulate API delay
	time.Sleep(300 * time.Millisecond)

	// Mock resource creation - generate a fake ID based on sandwich IDs
	var sandwichIds []types.String
	resp.Diagnostics.Append(data.SandwichIds.ElementsAs(ctx, &sandwichIds, false)...)
	if resp.Diagnostics.HasError() {
		return
	}
	
	id := fmt.Sprintf("bag-%d-sandwiches", len(sandwichIds))
	data.Id = types.StringValue(id)

	tflog.Trace(ctx, "created a bag resource", map[string]any{
		"id":           data.Id.ValueString(),
		"sandwich_ids": len(sandwichIds),
	})

	// Save data into Terraform state
	resp.Diagnostics.Append(resp.State.Set(ctx, &data)...)
}

func (r *BagResource) Read(ctx context.Context, req resource.ReadRequest, resp *resource.ReadResponse) {
	var data BagResourceModel

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

func (r *BagResource) Update(ctx context.Context, req resource.UpdateRequest, resp *resource.UpdateResponse) {
	var data BagResourceModel

	// Read Terraform plan data into the model
	resp.Diagnostics.Append(req.Plan.Get(ctx, &data)...)

	if resp.Diagnostics.HasError() {
		return
	}

	// Simulate API delay
	time.Sleep(300 * time.Millisecond)

	// Mock resource update - regenerate ID if sandwich_ids changed
	var state BagResourceModel
	resp.Diagnostics.Append(req.State.Get(ctx, &state)...)
	if resp.Diagnostics.HasError() {
		return
	}

	// If sandwich_ids changed, regenerate ID
	if !data.SandwichIds.Equal(state.SandwichIds) {
		var sandwichIds []types.String
		resp.Diagnostics.Append(data.SandwichIds.ElementsAs(ctx, &sandwichIds, false)...)
		if resp.Diagnostics.HasError() {
			return
		}
		id := fmt.Sprintf("bag-%d-sandwiches", len(sandwichIds))
		data.Id = types.StringValue(id)
	} else {
		// Keep existing ID
		data.Id = state.Id
	}

	// Save updated data into Terraform state
	resp.Diagnostics.Append(resp.State.Set(ctx, &data)...)
}

func (r *BagResource) Delete(ctx context.Context, req resource.DeleteRequest, resp *resource.DeleteResponse) {
	var data BagResourceModel

	// Read Terraform prior state data into the model
	resp.Diagnostics.Append(req.State.Get(ctx, &data)...)

	if resp.Diagnostics.HasError() {
		return
	}

	// Simulate API delay
	time.Sleep(300 * time.Millisecond)

	// Mock resource deletion - nothing to do
	tflog.Trace(ctx, "deleted a bag resource", map[string]any{
		"id": data.Id.ValueString(),
	})
}

func (r *BagResource) ImportState(ctx context.Context, req resource.ImportStateRequest, resp *resource.ImportStateResponse) {
	resource.ImportStatePassthroughID(ctx, path.Root("id"), req, resp)
}

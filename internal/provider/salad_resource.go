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
var _ resource.Resource = &SaladResource{}
var _ resource.ResourceWithImportState = &SaladResource{}

func NewSaladResource() resource.Resource {
	return &SaladResource{}
}

// SaladResource defines the resource implementation.
type SaladResource struct {
	client *ProviderConfig
}

// SaladResourceModel describes the resource data model.
type SaladResourceModel struct {
	Description types.String `tfsdk:"description"`
	Kind        types.String `tfsdk:"kind"`
	Dressing    types.String `tfsdk:"dressing"`
	Size        types.String `tfsdk:"size"`
	Price       types.Number `tfsdk:"price"`
	Id          types.String `tfsdk:"id"`
}

func (r *SaladResource) Metadata(ctx context.Context, req resource.MetadataRequest, resp *resource.MetadataResponse) {
	resp.TypeName = req.ProviderTypeName + "_salad"
}

func (r *SaladResource) Schema(ctx context.Context, req resource.SchemaRequest, resp *resource.SchemaResponse) {
	resp.Schema = schema.Schema{
		MarkdownDescription: `A fresh and healthy option that showcases multiple string attributes working together. Learn about resource configuration while building the perfect crisp, green meal.

*Fresh greens in a bowl,*
*Dressing drizzled with care,*
*Nature's crisp delight.*`,

		Attributes: map[string]schema.Attribute{
			"description": schema.StringAttribute{
				MarkdownDescription: "A description of the salad resource",
				Optional:            true,
			},
			"kind": schema.StringAttribute{
				MarkdownDescription: "The kind of salad (e.g., caesar, garden, cobb)",
				Required:            true,
			},
			"dressing": schema.StringAttribute{
				MarkdownDescription: "The dressing for the salad (e.g., ranch, vinaigrette, caesar)",
				Required:            true,
			},
			"size": schema.StringAttribute{
				MarkdownDescription: "The size of the salad (small, medium, large)",
				Required:            true,
			},
			"price": schema.NumberAttribute{
				Computed:            true,
				MarkdownDescription: "The price of the salad in dollars (hardcoded to $4.00)",
			},
			"id": schema.StringAttribute{
				Computed:            true,
				MarkdownDescription: "Salad identifier",
				PlanModifiers: []planmodifier.String{
					stringplanmodifier.UseStateForUnknown(),
				},
			},
		},
	}
}

func (r *SaladResource) Configure(ctx context.Context, req resource.ConfigureRequest, resp *resource.ConfigureResponse) {
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

func (r *SaladResource) Create(ctx context.Context, req resource.CreateRequest, resp *resource.CreateResponse) {
	var data SaladResourceModel

	// Read Terraform plan data into the model
	resp.Diagnostics.Append(req.Plan.Get(ctx, &data)...)

	if resp.Diagnostics.HasError() {
		return
	}

	// Simulate API delay

	// Set base price: $4.00, then apply upcharge
	basePrice := big.NewFloat(4.00)
	finalPrice := ApplyUpcharge(basePrice, r.client.Upcharge)
	data.Price = types.NumberValue(finalPrice)

	// Mock resource creation - generate a fake ID based on the kind
	id := fmt.Sprintf("salad-%s-%d", data.Kind.ValueString(), len(data.Kind.ValueString()))
	data.Id = types.StringValue(id)

	tflog.Trace(ctx, "created a salad resource", map[string]any{
		"id":       data.Id.ValueString(),
		"kind":     data.Kind.ValueString(),
		"dressing": data.Dressing.ValueString(),
		"size":     data.Size.ValueString(),
	})

	// Save data into Terraform state
	resp.Diagnostics.Append(resp.State.Set(ctx, &data)...)
}

func (r *SaladResource) Read(ctx context.Context, req resource.ReadRequest, resp *resource.ReadResponse) {
	var data SaladResourceModel

	// Read Terraform prior state data into the model
	resp.Diagnostics.Append(req.State.Get(ctx, &data)...)

	if resp.Diagnostics.HasError() {
		return
	}

	// Simulate API delay

	// Ensure price is set (in case it wasn't in state)
	data.Price = types.NumberValue(big.NewFloat(4.00))

	// Mock resource read - just return the existing state
	// In a real implementation, this would fetch from an API

	// Save updated data into Terraform state
	resp.Diagnostics.Append(resp.State.Set(ctx, &data)...)
}

func (r *SaladResource) Update(ctx context.Context, req resource.UpdateRequest, resp *resource.UpdateResponse) {
	var data SaladResourceModel

	// Read Terraform plan data into the model
	resp.Diagnostics.Append(req.Plan.Get(ctx, &data)...)

	if resp.Diagnostics.HasError() {
		return
	}

	// Simulate API delay

	// Ensure price is always set to $4.00
	data.Price = types.NumberValue(big.NewFloat(4.00))

	// Mock resource update - regenerate ID if kind changed
	var state SaladResourceModel
	resp.Diagnostics.Append(req.State.Get(ctx, &state)...)
	if resp.Diagnostics.HasError() {
		return
	}

	// If kind changed, regenerate ID
	if !data.Kind.Equal(state.Kind) {
		id := fmt.Sprintf("salad-%s-%d", data.Kind.ValueString(), len(data.Kind.ValueString()))
		data.Id = types.StringValue(id)
	} else {
		// Keep existing ID
		data.Id = state.Id
	}

	// Save updated data into Terraform state
	resp.Diagnostics.Append(resp.State.Set(ctx, &data)...)
}

func (r *SaladResource) Delete(ctx context.Context, req resource.DeleteRequest, resp *resource.DeleteResponse) {
	var data SaladResourceModel

	// Read Terraform prior state data into the model
	resp.Diagnostics.Append(req.State.Get(ctx, &data)...)

	if resp.Diagnostics.HasError() {
		return
	}

	// Simulate API delay

	// Mock resource deletion - nothing to do
	tflog.Trace(ctx, "deleted a salad resource", map[string]any{
		"id": data.Id.ValueString(),
	})
}

func (r *SaladResource) ImportState(ctx context.Context, req resource.ImportStateRequest, resp *resource.ImportStateResponse) {
	resource.ImportStatePassthroughID(ctx, path.Root("id"), req, resp)
}

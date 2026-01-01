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
var _ resource.Resource = &DogtreatResource{}
var _ resource.ResourceWithImportState = &DogtreatResource{}

func NewDogtreatResource() resource.Resource {
	return &DogtreatResource{}
}

// DogtreatResource defines the resource implementation.
type DogtreatResource struct {
	client *ProviderConfig
}

// DogtreatResourceModel describes the resource data model.
type DogtreatResourceModel struct {
	Description types.String `tfsdk:"description"`
	IsGoodDog   types.Bool   `tfsdk:"is_good_dog"`
	Size        types.String  `tfsdk:"size"`
	Price       types.Number `tfsdk:"price"`
	Id          types.String `tfsdk:"id"`
}

func (r *DogtreatResource) Metadata(ctx context.Context, req resource.MetadataRequest, resp *resource.MetadataResponse) {
	resp.TypeName = req.ProviderTypeName + "_dogtreat"
}

func (r *DogtreatResource) Schema(ctx context.Context, req resource.SchemaRequest, resp *resource.SchemaResponse) {
	resp.Schema = schema.Schema{
		MarkdownDescription: "Mock dog treat resource for instructional purposes. Size is determined by is_good_dog attribute.",

		Attributes: map[string]schema.Attribute{
			"description": schema.StringAttribute{
				MarkdownDescription: "A description of the dog treat resource",
				Optional:            true,
			},
			"is_good_dog": schema.BoolAttribute{
				MarkdownDescription: "Whether the dog is a good dog. If true, the treat will be large; if false, it will be small.",
				Required:            true,
			},
			"size": schema.StringAttribute{
				Computed:            true,
				MarkdownDescription: "The size of the treat (large or small), determined by is_good_dog",
			},
			"price": schema.NumberAttribute{
				Computed:            true,
				MarkdownDescription: "The price of the dog treat in dollars (large: $2.00, small: $1.00)",
			},
			"id": schema.StringAttribute{
				Computed:            true,
				MarkdownDescription: "Dog treat identifier",
				PlanModifiers: []planmodifier.String{
					stringplanmodifier.UseStateForUnknown(),
				},
			},
		},
	}
}

func (r *DogtreatResource) Configure(ctx context.Context, req resource.ConfigureRequest, resp *resource.ConfigureResponse) {
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

func (r *DogtreatResource) Create(ctx context.Context, req resource.CreateRequest, resp *resource.CreateResponse) {
	var data DogtreatResourceModel

	// Read Terraform plan data into the model
	resp.Diagnostics.Append(req.Plan.Get(ctx, &data)...)

	if resp.Diagnostics.HasError() {
		return
	}

	// Simulate API delay

	// Determine size and base price based on is_good_dog, then apply upcharge
	var basePrice *big.Float
	if data.IsGoodDog.ValueBool() {
		data.Size = types.StringValue("large")
		basePrice = big.NewFloat(2.00)
	} else {
		data.Size = types.StringValue("small")
		basePrice = big.NewFloat(1.00)
	}
	finalPrice := ApplyUpcharge(basePrice, r.client.Upcharge)
	data.Price = types.NumberValue(finalPrice)

	// Mock resource creation - generate a fake ID
	sizeStr := data.Size.ValueString()
	id := fmt.Sprintf("dogtreat-%s-%d", sizeStr, len(sizeStr))
	data.Id = types.StringValue(id)

	tflog.Trace(ctx, "created a dog treat resource", map[string]any{
		"id":         data.Id.ValueString(),
		"is_good_dog": data.IsGoodDog.ValueBool(),
		"size":       data.Size.ValueString(),
	})

	// Save data into Terraform state
	resp.Diagnostics.Append(resp.State.Set(ctx, &data)...)
}

func (r *DogtreatResource) Read(ctx context.Context, req resource.ReadRequest, resp *resource.ReadResponse) {
	var data DogtreatResourceModel

	// Read Terraform prior state data into the model
	resp.Diagnostics.Append(req.State.Get(ctx, &data)...)

	if resp.Diagnostics.HasError() {
		return
	}

	// Simulate API delay

	// Recalculate size and price based on is_good_dog
	if data.IsGoodDog.ValueBool() {
		data.Size = types.StringValue("large")
		data.Price = types.NumberValue(big.NewFloat(2.00))
	} else {
		data.Size = types.StringValue("small")
		data.Price = types.NumberValue(big.NewFloat(1.00))
	}

	// Mock resource read - just return the existing state
	// In a real implementation, this would fetch from an API

	// Save updated data into Terraform state
	resp.Diagnostics.Append(resp.State.Set(ctx, &data)...)
}

func (r *DogtreatResource) Update(ctx context.Context, req resource.UpdateRequest, resp *resource.UpdateResponse) {
	var data DogtreatResourceModel

	// Read Terraform plan data into the model
	resp.Diagnostics.Append(req.Plan.Get(ctx, &data)...)

	if resp.Diagnostics.HasError() {
		return
	}

	// Simulate API delay

	// Recalculate size and price based on is_good_dog
	if data.IsGoodDog.ValueBool() {
		data.Size = types.StringValue("large")
		data.Price = types.NumberValue(big.NewFloat(2.00))
	} else {
		data.Size = types.StringValue("small")
		data.Price = types.NumberValue(big.NewFloat(1.00))
	}

	// Mock resource update - regenerate ID if is_good_dog changed (which changes size)
	var state DogtreatResourceModel
	resp.Diagnostics.Append(req.State.Get(ctx, &state)...)
	if resp.Diagnostics.HasError() {
		return
	}

	// If is_good_dog changed, regenerate ID
	if !data.IsGoodDog.Equal(state.IsGoodDog) {
		sizeStr := data.Size.ValueString()
		id := fmt.Sprintf("dogtreat-%s-%d", sizeStr, len(sizeStr))
		data.Id = types.StringValue(id)
	} else {
		// Keep existing ID
		data.Id = state.Id
	}

	// Save updated data into Terraform state
	resp.Diagnostics.Append(resp.State.Set(ctx, &data)...)
}

func (r *DogtreatResource) Delete(ctx context.Context, req resource.DeleteRequest, resp *resource.DeleteResponse) {
	var data DogtreatResourceModel

	// Read Terraform prior state data into the model
	resp.Diagnostics.Append(req.State.Get(ctx, &data)...)

	if resp.Diagnostics.HasError() {
		return
	}

	// Simulate API delay

	// Mock resource deletion - nothing to do
	tflog.Trace(ctx, "deleted a dog treat resource", map[string]any{
		"id": data.Id.ValueString(),
	})
}

func (r *DogtreatResource) ImportState(ctx context.Context, req resource.ImportStateRequest, resp *resource.ImportStateResponse) {
	resource.ImportStatePassthroughID(ctx, path.Root("id"), req, resp)
}

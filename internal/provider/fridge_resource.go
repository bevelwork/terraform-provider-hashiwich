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

var _ resource.Resource = &FridgeResource{}
var _ resource.ResourceWithImportState = &FridgeResource{}

func NewFridgeResource() resource.Resource {
	return &FridgeResource{}
}

type FridgeResource struct {
	client *ProviderConfig
}

type FridgeResourceModel struct {
	Size        types.String `tfsdk:"size"`
	Description types.String `tfsdk:"description"`
	Cost        types.Number `tfsdk:"cost"`
	Id          types.String `tfsdk:"id"`
}

func (r *FridgeResource) Metadata(ctx context.Context, req resource.MetadataRequest, resp *resource.MetadataResponse) {
	resp.TypeName = req.ProviderTypeName + "_fridge"
}

func (r *FridgeResource) Schema(ctx context.Context, req resource.SchemaRequest, resp *resource.SchemaResponse) {
	resp.Schema = schema.Schema{
		MarkdownDescription: `Essential cold storage that keeps ingredients fresh and ready. Demonstrates size-based resource configuration and cost calculations, teaching how infrastructure components scale with your business needs.

*Cool air preserves,*
*Fresh ingredients waiting,*
*Silent guardian stands.*`,

		Attributes: map[string]schema.Attribute{
			"size": schema.StringAttribute{
				MarkdownDescription: "Size of fridge (small=$300, medium=$500, large=$800)",
				Required:            true,
			},
			"description": schema.StringAttribute{
				MarkdownDescription: "Description of the fridge",
				Optional:            true,
			},
			"cost": schema.NumberAttribute{
				Computed:            true,
				MarkdownDescription: "Cost of the fridge in dollars",
			},
			"id": schema.StringAttribute{
				Computed:            true,
				MarkdownDescription: "Fridge identifier",
				PlanModifiers: []planmodifier.String{
					stringplanmodifier.UseStateForUnknown(),
				},
			},
		},
	}
}

func (r *FridgeResource) Configure(ctx context.Context, req resource.ConfigureRequest, resp *resource.ConfigureResponse) {
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

func (r *FridgeResource) Create(ctx context.Context, req resource.CreateRequest, resp *resource.CreateResponse) {
	var data FridgeResourceModel

	resp.Diagnostics.Append(req.Plan.Get(ctx, &data)...)
	if resp.Diagnostics.HasError() {
		return
	}


	// Calculate cost based on size
	var basePrice *big.Float
	size := data.Size.ValueString()
	switch size {
	case "small":
		basePrice = big.NewFloat(300.00)
	case "medium":
		basePrice = big.NewFloat(500.00)
	case "large":
		basePrice = big.NewFloat(800.00)
	default:
		basePrice = big.NewFloat(300.00) // default to small
	}

	finalPrice := ApplyUpcharge(basePrice, r.client.Upcharge)
	data.Cost = types.NumberValue(finalPrice)

	id := fmt.Sprintf("fridge-%s-%d", size, len(size))
	data.Id = types.StringValue(id)

	tflog.Trace(ctx, "created a fridge resource", map[string]any{
		"id":   data.Id.ValueString(),
		"size": size,
		"cost": data.Cost.ValueBigFloat().String(),
	})

	resp.Diagnostics.Append(resp.State.Set(ctx, &data)...)
}

func (r *FridgeResource) Read(ctx context.Context, req resource.ReadRequest, resp *resource.ReadResponse) {
	var data FridgeResourceModel

	resp.Diagnostics.Append(req.State.Get(ctx, &data)...)
	if resp.Diagnostics.HasError() {
		return
	}


	// Recalculate cost
	var basePrice *big.Float
	size := data.Size.ValueString()
	switch size {
	case "small":
		basePrice = big.NewFloat(300.00)
	case "medium":
		basePrice = big.NewFloat(500.00)
	case "large":
		basePrice = big.NewFloat(800.00)
	default:
		basePrice = big.NewFloat(300.00)
	}

	finalPrice := ApplyUpcharge(basePrice, r.client.Upcharge)
	data.Cost = types.NumberValue(finalPrice)

	resp.Diagnostics.Append(resp.State.Set(ctx, &data)...)
}

func (r *FridgeResource) Update(ctx context.Context, req resource.UpdateRequest, resp *resource.UpdateResponse) {
	var data FridgeResourceModel

	resp.Diagnostics.Append(req.Plan.Get(ctx, &data)...)
	if resp.Diagnostics.HasError() {
		return
	}


	// Recalculate cost
	var basePrice *big.Float
	size := data.Size.ValueString()
	switch size {
	case "small":
		basePrice = big.NewFloat(300.00)
	case "medium":
		basePrice = big.NewFloat(500.00)
	case "large":
		basePrice = big.NewFloat(800.00)
	default:
		basePrice = big.NewFloat(300.00)
	}

	finalPrice := ApplyUpcharge(basePrice, r.client.Upcharge)
	data.Cost = types.NumberValue(finalPrice)

	var state FridgeResourceModel
	resp.Diagnostics.Append(req.State.Get(ctx, &state)...)
	if resp.Diagnostics.HasError() {
		return
	}

	if !data.Size.Equal(state.Size) {
		id := fmt.Sprintf("fridge-%s-%d", size, len(size))
		data.Id = types.StringValue(id)
	} else {
		data.Id = state.Id
	}

	resp.Diagnostics.Append(resp.State.Set(ctx, &data)...)
}

func (r *FridgeResource) Delete(ctx context.Context, req resource.DeleteRequest, resp *resource.DeleteResponse) {
	var data FridgeResourceModel

	resp.Diagnostics.Append(req.State.Get(ctx, &data)...)
	if resp.Diagnostics.HasError() {
		return
	}


	tflog.Trace(ctx, "deleted a fridge resource", map[string]any{
		"id": data.Id.ValueString(),
	})
}

func (r *FridgeResource) ImportState(ctx context.Context, req resource.ImportStateRequest, resp *resource.ImportStateResponse) {
	resource.ImportStatePassthroughID(ctx, path.Root("id"), req, resp)
}

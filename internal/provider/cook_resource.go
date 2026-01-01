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

var _ resource.Resource = &CookResource{}
var _ resource.ResourceWithImportState = &CookResource{}

func NewCookResource() resource.Resource {
	return &CookResource{}
}

type CookResource struct {
	client *ProviderConfig
}

type CookResourceModel struct {
	Name        types.String `tfsdk:"name"`
	Experience  types.String `tfsdk:"experience"`
	Description types.String `tfsdk:"description"`
	Cost        types.Number `tfsdk:"cost"`
	Id          types.String `tfsdk:"id"`
}

func (r *CookResource) Metadata(ctx context.Context, req resource.MetadataRequest, resp *resource.MetadataResponse) {
	resp.TypeName = req.ProviderTypeName + "_cook"
}

func (r *CookResource) Schema(ctx context.Context, req resource.SchemaRequest, resp *resource.SchemaResponse) {
	resp.Schema = schema.Schema{
		MarkdownDescription: "Cook resource for sandwich shop. Required for hw_store. Cost represents daily wage.",

		Attributes: map[string]schema.Attribute{
			"name": schema.StringAttribute{
				MarkdownDescription: "Name of the cook",
				Required:            true,
			},
			"experience": schema.StringAttribute{
				MarkdownDescription: "Experience level (junior, experienced, expert). Affects cost and efficiency.",
				Required:            true,
			},
			"description": schema.StringAttribute{
				MarkdownDescription: "Description of the cook",
				Optional:            true,
			},
			"cost": schema.NumberAttribute{
				Computed:            true,
				MarkdownDescription: "Daily cost in dollars (junior=$120/day, experienced=$160/day, expert=$200/day)",
			},
			"id": schema.StringAttribute{
				Computed:            true,
				MarkdownDescription: "Cook identifier",
				PlanModifiers: []planmodifier.String{
					stringplanmodifier.UseStateForUnknown(),
				},
			},
		},
	}
}

func (r *CookResource) Configure(ctx context.Context, req resource.ConfigureRequest, resp *resource.ConfigureResponse) {
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

func (r *CookResource) Create(ctx context.Context, req resource.CreateRequest, resp *resource.CreateResponse) {
	var data CookResourceModel

	resp.Diagnostics.Append(req.Plan.Get(ctx, &data)...)
	if resp.Diagnostics.HasError() {
		return
	}


	// Calculate cost based on experience
	var basePrice *big.Float
	experience := data.Experience.ValueString()
	switch experience {
	case "junior":
		basePrice = big.NewFloat(120.00)
	case "experienced":
		basePrice = big.NewFloat(160.00)
	case "expert":
		basePrice = big.NewFloat(200.00)
	default:
		basePrice = big.NewFloat(120.00) // default to junior
	}

	finalPrice := ApplyUpcharge(basePrice, r.client.Upcharge)
	data.Cost = types.NumberValue(finalPrice)

	id := fmt.Sprintf("cook-%s-%d", data.Name.ValueString(), len(data.Name.ValueString()))
	data.Id = types.StringValue(id)

	tflog.Trace(ctx, "created a cook resource", map[string]any{
		"id":         data.Id.ValueString(),
		"name":       data.Name.ValueString(),
		"experience": experience,
		"cost":       data.Cost.ValueBigFloat().String(),
	})

	resp.Diagnostics.Append(resp.State.Set(ctx, &data)...)
}

func (r *CookResource) Read(ctx context.Context, req resource.ReadRequest, resp *resource.ReadResponse) {
	var data CookResourceModel

	resp.Diagnostics.Append(req.State.Get(ctx, &data)...)
	if resp.Diagnostics.HasError() {
		return
	}


	// Recalculate cost
	var basePrice *big.Float
	experience := data.Experience.ValueString()
	switch experience {
	case "junior":
		basePrice = big.NewFloat(120.00)
	case "experienced":
		basePrice = big.NewFloat(160.00)
	case "expert":
		basePrice = big.NewFloat(200.00)
	default:
		basePrice = big.NewFloat(120.00)
	}

	finalPrice := ApplyUpcharge(basePrice, r.client.Upcharge)
	data.Cost = types.NumberValue(finalPrice)

	resp.Diagnostics.Append(resp.State.Set(ctx, &data)...)
}

func (r *CookResource) Update(ctx context.Context, req resource.UpdateRequest, resp *resource.UpdateResponse) {
	var data CookResourceModel

	resp.Diagnostics.Append(req.Plan.Get(ctx, &data)...)
	if resp.Diagnostics.HasError() {
		return
	}


	// Recalculate cost
	var basePrice *big.Float
	experience := data.Experience.ValueString()
	switch experience {
	case "junior":
		basePrice = big.NewFloat(120.00)
	case "experienced":
		basePrice = big.NewFloat(160.00)
	case "expert":
		basePrice = big.NewFloat(200.00)
	default:
		basePrice = big.NewFloat(120.00)
	}

	finalPrice := ApplyUpcharge(basePrice, r.client.Upcharge)
	data.Cost = types.NumberValue(finalPrice)

	var state CookResourceModel
	resp.Diagnostics.Append(req.State.Get(ctx, &state)...)
	if resp.Diagnostics.HasError() {
		return
	}

	if !data.Name.Equal(state.Name) || !data.Experience.Equal(state.Experience) {
		id := fmt.Sprintf("cook-%s-%d", data.Name.ValueString(), len(data.Name.ValueString()))
		data.Id = types.StringValue(id)
	} else {
		data.Id = state.Id
	}

	resp.Diagnostics.Append(resp.State.Set(ctx, &data)...)
}

func (r *CookResource) Delete(ctx context.Context, req resource.DeleteRequest, resp *resource.DeleteResponse) {
	var data CookResourceModel

	resp.Diagnostics.Append(req.State.Get(ctx, &data)...)
	if resp.Diagnostics.HasError() {
		return
	}


	tflog.Trace(ctx, "deleted a cook resource", map[string]any{
		"id": data.Id.ValueString(),
	})
}

func (r *CookResource) ImportState(ctx context.Context, req resource.ImportStateRequest, resp *resource.ImportStateResponse) {
	resource.ImportStatePassthroughID(ctx, path.Root("id"), req, resp)
}

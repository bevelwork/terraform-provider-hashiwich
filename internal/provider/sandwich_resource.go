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
		MarkdownDescription: "Mock sandwich resource for instructional purposes. Combines bread and meat resources.",

		Attributes: map[string]schema.Attribute{
			"description": schema.StringAttribute{
				MarkdownDescription: "A description of the sandwich resource",
				Optional:            true,
			},
			"bread_id": schema.StringAttribute{
				MarkdownDescription: "The ID of the bread resource to use",
				Required:            true,
			},
			"meat_id": schema.StringAttribute{
				MarkdownDescription: "The ID of the meat resource to use",
				Required:            true,
			},
			"name": schema.StringAttribute{
				Computed:            true,
				MarkdownDescription: "The name of the sandwich in the format '{meat} on {bread}'",
				PlanModifiers: []planmodifier.String{
					stringplanmodifier.UseStateForUnknown(),
				},
			},
			"price": schema.NumberAttribute{
				Computed:            true,
				MarkdownDescription: "The price of the sandwich in dollars (hardcoded to $5.00)",
			},
			"id": schema.StringAttribute{
				Computed:            true,
				MarkdownDescription: "Sandwich identifier",
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

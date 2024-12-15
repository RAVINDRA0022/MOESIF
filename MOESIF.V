`timescale 1ns / 1ps

module MOESIF_PROTOCOL (
    input wire clk,
    input wire reset,
    input wire [2:0] state_in,
    input wire request,
    input wire invalidate,
    input wire snoop_hit,
    input wire write,
    input wire forward,
    output reg [2:0] state_out
);
    
    parameter INVALID = 3'b000;
    parameter SHARED = 3'b001;
    parameter EXCLUSIVE = 3'b010;
    parameter MODIFIED = 3'b011;
    parameter OWNED = 3'b100;
    parameter FORWARD_STATE = 3'b101;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state_out <= INVALID;
        end else begin
            case (state_in)
                INVALID: begin
                    if (write)
                        state_out <= MODIFIED;
                    else if (request && !write)
                        state_out <= EXCLUSIVE;
                    else
                        state_out <= INVALID;
                end

                SHARED: begin
                    if (invalidate)
                        state_out <= INVALID;
                    else if (write)
                        state_out <= MODIFIED;
                    else if (forward)
                        state_out <= FORWARD_STATE;
                    else
                        state_out <= SHARED;
                end

                EXCLUSIVE: begin
                    if (write)
                        state_out <= MODIFIED;
                    else if (snoop_hit)
                        state_out <= OWNED;
                    else
                        state_out <= EXCLUSIVE;
                end

                MODIFIED: begin
                    if (invalidate)
                        state_out <= INVALID;
                    else if (snoop_hit)
                        state_out <= OWNED;
                    else
                        state_out <= SHARED;
                end

                OWNED: begin
                    if (invalidate)
                        state_out <= INVALID;
                    else if (forward)
                        state_out <= FORWARD_STATE;
                    else
                        state_out <= SHARED;
                end

                FORWARD_STATE: begin
                    if (invalidate)
                        state_out <= INVALID;
                    else if (write)
                        state_out <= MODIFIED;
                    else if (!forward)
                        state_out <= SHARED;
                    else
                        state_out <= FORWARD_STATE;
                end

                default: state_out <= INVALID;
            endcase
        end
    end
endmodule

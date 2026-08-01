/* The Problem:
 * The game takes place on a 16x16 two-dimensional toroidal grid of square cells, 
 * represented as a flat 256-bit vector. Every cell interacts with its eight 
 * neighbors (horizontal, vertical, and diagonal) based on these four conditions 
 * at each clock cycle (or generation):
 *
 * Underpopulation: Any live cell with fewer than two live neighbors dies 
 *                  (as if by loneliness).
 * Survival:        Any live cell with two or three live neighbors lives on 
 *                  to the next generation.
 * Overpopulation:  Any live cell with more than three live neighbors dies 
 *                  (as if by overcrowding).
 * Reproduction:    Any dead cell with exactly three live neighbors becomes 
 *                  a live cell.
 *
 * The game state advances by one timestep every clock cycle, unless the 
 * 'load' signal is high, which populates the grid with an initial state.
 */

module top_module(
    input clk,
    input load,
    input [255:0] data,
    output [255:0] q ); 
    
    reg [3:0] r, c;
    reg [3:0] r_up, r_down, c_left, c_right;
    reg [3:0] count;
    
    always @(*) begin
        for (int i = 0; i < 256; i++) begin
            r = i /16;
            c = i % 16;
            
            r_up = r - 1;
            r_down = r + 1;
            c_left = c - 1;
            c_right = c + 1;
            count = q[{r_up, c_left}]   + q[{r_up, c}]   + q[{r_up, c_right}] +
                    q[{r, c_left}]                       + q[{r, c_right}] +
                    q[{r_down, c_left}] + q[{r_down, c}] + q[{r_down, c_right}];
            
            if (count == 3) 
                next_q[i] = 1'b1;
            else if (count == 2)
                next_q[i] = q[i]; 
            else next_q[i] = 1'b0;
        end
    end
    
    always @(posedge clk) begin
        if (load)
            q <= data;
        else 
            q <= next_q;
    end

endmodule

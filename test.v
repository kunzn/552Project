module test_shift();
  reg  signed [15:0] A;
  wire signed [15:0] Out;
  reg [3:0] shift;
  reg [1:0] Mode;

  integer i;
  reg error;	// used to check if testbench failed
  
  Shifter shifter (.Shift_Out(Out), .Shift_In(A), .Shift_Val(shift), .Mode(Mode));

  initial begin
    $monitor("A:%h Shift:%h Out:%h Mode:%b", A, shift, Out, Mode);
    error = 0;
    for (i = 0; i < 20; i = i + 1) begin
      A = $random;
      shift = $random;
      Mode = $random ;
      #20;
      if (Mode == 2'b00) begin
        if (Out != (A << shift)) begin
	  $display("A:%h ,Out:%h ,A<<shift:%h", A, Out, A << shift);
	  error = 1;
	end
      end else if (Mode == 2'b01)begin
        if (Out != (A >>> shift)) begin
	  $display("A:%h ,Out:%h ,A>>>shift:%h", A, Out, A >>> shift);
	  error = 1;
	end
      end
    end
    if (!error) begin
      $display("YAHOOO!");
    end
  end
endmodule
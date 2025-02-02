`timescale 1ns / 1ps
/****************************************************************************
* File Name:          CU.V
* Project:            Lab Project 8: RISC Processor
* Used by:            Houssem Eddin Loudhabachi and Jose Sotelo
* Email:              jsotelo235@gmail.com and hloudhabachi@gmail.com
* Rev. Date:          May 11, 2017
*
* Purpose:
* A "Moore" finite state machine that implements the major cycles for
* fetching and executing instructions for the 301 16-bit RISC Processor.
*
* The Control Unit (CU) is a component of a computer's central processing
* unit that directs the operation of the processor. It tells the computer's
* memory, arithmetic logic unit, and I/O devices on how to respond
* to a program's instructions.
*****************************************************************************/
module CU(clk,      reset,    IR,       N,        Z,        C,  
          W_Adr,    R_Adr,    S_Adr,                             
          adr_sel,  s_sel,                                      
          pc_ld,    pc_inc,   pc_sel,   ir_ld,                    
          mw_en,    rw_en,    alu_op,                            
          status);                                            

     input               clk, reset;    // clock and reset
     input     [15:0]    IR;            // instruction register input
     input               N,   Z,   C;   // datapath status inputs
     
     output    [2:0]     W_Adr,         // register file address outputs
                         R_Adr,    
                         S_Adr;              
                         
     output              adr_sel,       // mux select outputs
                         s_sel;                        
                         
     output              pc_ld,         // pc load, pc inc, pc select, ir load  
                         pc_inc,   
                         pc_sel,   
                         ir_ld;    
                         
     output              mw_en,         // memory_write, register_file write
                         rw_en;                        
                         
     output    [3:0]     alu_op;        // ALU opcode output
     output    [7:0]     status;        // 8 LED outputs current state
     
     //********************************************
     //             Data Structures
     //   Control words make up the Control Unit
     //********************************************
     
     reg       [2:0]     W_Adr,    R_Adr,    S_Adr;   
     reg                 adr_sel,  s_sel;              
     reg                 pc_ld,    pc_inc;             
     reg                 pc_sel,   ir_ld;              
     reg                 mw_en,    rw_en;              
     reg       [3:0]     alu_op;                       
     
     reg       [4:0]     state;              // preset stae register
     reg       [4:0]     nextstate;          // next state register
     reg       [7:0]     status;             // LED status/state outputs
     reg                 ps_N, ps_Z, ps_C;   // preset state flags register
     reg                 ns_N, ns_Z, ns_C;   // next state flags register
     
     parameter RESET = 0,     FETCH = 1,     DECODE = 2,
               ADD = 3,       SUB = 4,       CMP = 5,       MOV = 6,
               INC = 7,       DEC = 8,       SHL = 9,       SHR = 10,
               LD = 11,       STO = 12,      LDI = 13,
               JE = 14,       JNE = 15,      JC = 16,       JMP = 17,
               HALT = 18,
               ILLEGAL_OP = 311;
                         
     //*****************************************
     // 301 Control Unit Sequencer
     //*****************************************
     
     // synchronous flags register assignment 
     always @ (posedge clk or posedge reset)
          if (reset)
               {ps_N, ps_Z, ps_C} = 3'b0;
          else
               {ps_N, ps_Z, ps_C} = {ns_N, ns_Z, ps_C};

     // combinational logic section for both next state logic
     // and control word outputs for cpu_execution_unit and memory
     always @( state )
          case ( state )
          
          // Reset
          // Default Control Word Values -- LED pattern = 1111_111
          RESET:    begin
               W_Adr     = 3'b000;      R_Adr     = 3'b000;   S_Adr  = 3'b000;
               adr_sel   = 1'b0;        s_sel     = 1'b0;
               pc_ld     = 1'b0;        pc_inc    = 1'b0;     pc_sel = 1'b0;      
                                                              ir_ld  = 1'b0;
               mw_en     = 1'b0;        rw_en     = 1'b0;     alu_op = 4'b0000;
               
               {ns_N,ns_Z,ns_C} = 3'b0;
               status = 8'hFF;
               nextstate = FETCH;
          end
          
          // Fetch
          // IR <-- M[PC],    PC <- PC + 1 -- LED pattern = 1000_000
          FETCH:    begin
               W_Adr     = 3'b000;      R_Adr     = 3'b000;   S_Adr  = 3'b000;
               adr_sel   = 1'b0;        s_sel     = 1'b0;
               pc_ld     = 1'b0;        pc_inc    = 1'b1;     pc_sel = 1'b0;      
                                                              ir_ld  = 1'b1;
               
               mw_en     = 1'b0;        rw_en     = 1'b0;     alu_op = 4'b0000;
               
               {ns_N,ns_Z,ns_C} = {ps_N, ps_Z, ps_C};
               status = 8'h80; 
               nextstate = DECODE;
          end
          
          // Decode
          // Default Control Word, NS <- case(IR[15:9])
          // LED pattern = 1100_0000
          DECODE:   begin
               W_Adr     = 3'b000;      R_Adr     = 3'b000;   S_Adr  = 3'b000;
               adr_sel   = 1'b0;        s_sel     = 1'b0;
               pc_ld     = 1'b0;        pc_inc    = 1'b0;     pc_sel = 1'b0;      
                                                              ir_ld  = 1'b0;
               mw_en     = 1'b0;        rw_en     = 1'b0;     alu_op = 4'b0000;
               {ns_N,ns_Z,ns_C}= {ps_N,ps_Z,ps_C};
               status = 8'hC0;
               case ( IR[15:9] )
                    7'h70:    nextstate      = ADD;
                    7'h71:    nextstate      = SUB;
                    7'h72:    nextstate      = CMP;
                    7'h73:    nextstate      = MOV;
                    7'h74:    nextstate      = SHL;
                    7'h75:    nextstate      = SHR;
                    7'h76:    nextstate      = INC;
                    7'h77:    nextstate      = DEC;
                    7'h78:    nextstate      = LD;
                    7'h79:    nextstate      = STO;
                    7'h7a:    nextstate      = LDI;
                    7'h7b:    nextstate      = HALT;
                    7'h7c:    nextstate      = JE;
                    7'h7d:    nextstate      = JNE;
                    7'h7e:    nextstate      = JC;
                    7'h7f:    nextstate      = JMP;
                    default:  nextstate      = ILLEGAL_OP;
               endcase
            end
          
          // ADD
          // R[ir(8:6)] <- R[ir(5:3)] + R[ir(2:0)]
          // LED pattern = {ps_N,ps_Z,ps_C, 5'b00000}
          ADD:      begin 
               W_Adr   =    IR[8:6];   R_Adr     = IR[5:3]; S_Adr  = IR[2:0];
               adr_sel =    1'b0;      s_sel     = 1'b0;
               pc_ld   =    1'b0;      pc_inc    = 1'b0;    pc_sel = 1'b0;      
                                                            ir_ld  = 1'b0;
               mw_en   =    1'b0;      rw_en     = 1'b1;    alu_op = 4'b0100;
               
               {ns_N,ns_Z,ns_C} = {N,Z,C};
               nextstate = FETCH;
               status = {ps_N,ps_Z,ps_C,5'b00000};
          end
          
          // SUB
          // R[ir(8:6)] <- R[ir(5:3)] - R[ir(2:0)]
          // LED pattern = {ps_N,ps_Z,ps_C, 5'b00000}
          SUB:      begin
               W_Adr   = IR[8:6]; R_Adr  = IR[5:3];  S_Adr  = IR[2:0];
               adr_sel = 1'b0;    s_sel  = 1'b0;
               pc_ld   = 1'b0;    pc_inc = 1'b0;     pc_sel = 1'b0;      
                                                     ir_ld  = 1'b0;
                                                     
               mw_en   = 1'b0;    rw_en  = 1'b1;     alu_op = 4'b0101;
               {ns_N,ns_Z,ns_C} = {N,Z,C};
               nextstate = FETCH;
               status = {ps_N,ps_Z,ps_C,5'b00001};
          end
          
          // CMP
          // R[ir(5:3)] - R[ir(2:0)]
          // LED pattern = {ps_N,ps_Z,ps_C, 5'b0010}
          CMP:      begin     
               W_Adr   = 3'b000;   R_Adr  = IR[5:3]; S_Adr  = IR[2:0];
               adr_sel = 1'b0;     s_sel  = 1'b0;
               pc_ld   = 1'b0;     pc_inc = 1'b0;    pc_sel = 1'b0;      
                                                     ir_ld  = 1'b0;
               mw_en   = 1'b0;     rw_en  = 1'b0;    alu_op = 4'b0101;
               {ns_N,ns_Z,ns_C} = {N,Z,C};
               nextstate = FETCH;
               status = {ps_N,ps_Z,ps_C,5'b00010};
          end
          
          // MOV
          // R[ir(8:6)] <- R[ir(5:3)] - R[ir(2:0)]
          // LED pattern = {ps_N,ps_Z,ps_C, 5'b0011}
          MOV:      begin
               W_Adr   = IR[8:6];  R_Adr  = 3'b000;    S_Adr  = IR[2:0];
               adr_sel = 1'b0;     s_sel  = 1'b0;
               pc_ld   = 1'b0;     pc_inc = 1'b0;      pc_sel = 1'b0;      
                                                       ir_ld  = 1'b0;
               mw_en   = 1'b0;     rw_en  = 1'b1;      alu_op = 4'b0000;
               {ns_N,ns_Z,ns_C} = {ps_N, ps_Z, ps_C};   
               nextstate = FETCH;
               status = {ps_N,ps_Z,ps_C,5'b00011};
          end
          
          // SHL
          // R[ir(8:6)]<-R[ir(2:0)] << 1
          // LED pattern = {ps_N,ps_Z,ps_C,5'b00100}
          SHL:      begin
               W_Adr   = IR[8:6];  R_Adr  = 3'b000;    S_Adr  = IR[2:0];
               adr_sel = 1'b0;     s_sel  = 1'b0;
               pc_ld   = 1'b0;     pc_inc = 1'b0;      pc_sel = 1'b0;      
                                                       ir_ld  = 1'b0;
               mw_en   = 1'b0;     rw_en  = 1'b1;      alu_op = 4'b0111;
               {ns_N,ns_Z,ns_C} = {N,Z,C};
               nextstate = FETCH;
               status = {ps_N,ps_Z,ps_C,5'b00100};
          end
          
          // SHR
          // R[ir(8:6)]<-R[ir(2:0)] >> 1
          // LED pattern = {ps_N,ps_Z,ps_C,5'b00101}
          SHR:      begin
               W_Adr   = IR[8:6];  R_Adr  = 3'b000;    S_Adr  = IR[2:0];
               adr_sel = 1'b0;     s_sel  = 1'b0;
               pc_ld   = 1'b0;     pc_inc = 1'b0;      pc_sel = 1'b0;      
                                                       ir_ld  = 1'b0;
               mw_en   = 1'b0;     rw_en  = 1'b1;      alu_op = 4'b0110;
               {ns_N,ns_Z,ns_C} = {N,Z,C};
               nextstate = FETCH;
               status = {ps_N,ps_Z,ps_C,5'b00101};
          end
          
          // INC
          // R[ir(8:6)]<-R[ir(2:0)] + 1
          // LED pattern = {ps_N,ps_Z,ps_C,5'b00110}
          INC:      begin
               W_Adr   = IR[8:6];  R_Adr  = 3'b000;    S_Adr  = IR[2:0];
               adr_sel = 1'b0;     s_sel  = 1'b0;
               pc_ld   = 1'b0;     pc_inc = 1'b0;      pc_sel = 1'b0;      
                                                       ir_ld  = 1'b0;
               mw_en   = 1'b0;     rw_en  = 1'b1;      alu_op = 4'b0010;
               {ns_N,ns_Z,ns_C} = {N,Z,C};
               nextstate = FETCH;
               status = {ps_N,ps_Z,ps_C,5'b00110};
          end
          
          // DEC
          // R[ir(8:6)]<-R[ir(2:0)] - 1
          // LED pattern = {ps_N,ps_Z,ps_C,5'b00111}
          DEC:      begin
               W_Adr   = IR[8:6];  R_Adr  = 3'b000;    S_Adr  = IR[2:0];
               adr_sel = 1'b0;     s_sel  = 1'b0;
               pc_ld   = 1'b0;     pc_inc = 1'b0;      pc_sel = 1'b0;        
                                                       ir_ld  = 1'b0;
               mw_en   = 1'b0;     rw_en  = 1'b1;      alu_op = 4'b0011;
               {ns_N,ns_Z,ns_C} = {N,Z,C};
               nextstate = FETCH;
               status = {ps_N,ps_Z,ps_C,5'b00111};
          end
          
          // LD
          // R[ir(8:6)]<-M[R[ir(2:0)]]
          // LED pattern = {ps_N,ps_Z,ps_C,5'b01000}
          LD:       begin
               W_Adr   = IR[8:6];  R_Adr  = IR[2:0];   S_Adr  = 3'b000;
               adr_sel = 1'b1;     s_sel  = 1'b1; 
               pc_ld   = 1'b0;     pc_inc = 1'b0;      pc_sel = 1'b0;      
                                                       ir_ld  =1'b0;
               mw_en   = 1'b0;     rw_en  = 1'b1;      alu_op = 4'b0000;
               {ns_N,ns_Z,ns_C} = {ps_N,ps_Z,ps_C};
               nextstate = FETCH;
               status = {ps_N,ps_Z,ps_C,5'b01000};
          end
          
          // STO
          // M[R[ir(8:6)]]<-R[ir(2:0)]
          // led pattern ={ps_N,ps_Z,ps_C,5'b01001}
          STO:      begin       
               W_Adr   = 3'b000;   R_Adr  = IR[8:6];   S_Adr  = IR[2:0];
               adr_sel = 1'b1;     s_sel  = 1'b0;
               pc_ld   = 1'b0;     pc_inc = 1'b0;      pc_sel = 1'b0;      
                                                       ir_ld  = 1'b0;
               mw_en   = 1'b1;     rw_en  = 1'b0;      alu_op = 4'b0000;
               {ns_N,ns_Z,ns_C} = {ps_N,ps_Z,ps_C};
               nextstate = FETCH;
               status = {ps_N,ps_Z,ps_C,5'b01001};
          end

          // LDI
          // R[ir(8:6)]<- M[PC], Pc<-PC+1
          // Led pattern={ps_N,ps_Z,ps_C,5'b01010}
          LDI:      begin          
               W_Adr   = IR[8:6];  R_Adr  = 3'b000;    S_Adr  = 3'b000;
               adr_sel = 1'b0;     s_sel  = 1'b1;
               pc_ld   = 1'b0;     pc_inc = 1'b1;      pc_sel = 1'b0;      
                                                       ir_ld  = 1'b0;
               mw_en   = 1'b0;     rw_en  = 1'b1;      alu_op = 4'b0000;
               {ns_N,ns_Z,ns_C} = {ps_N,ps_Z,ps_C};
               nextstate = FETCH;
               status = {ps_N,ps_Z,ps_C,5'b01010};
          end
          
          // JE
          // if (ps_z==1)  PC<-PC+SE_IR[7:0] else PC<-PC
          // LED pattern ={ps_N,ps_Z,ps_C,5'b01100}
          JE:       begin
               W_Adr   = 3'b000;   R_Adr  = 3'b000;    S_Adr = 3'b000;
               adr_sel = 1'b0;     s_sel  = 1'b0;
               pc_ld   = ps_Z;     pc_inc = 1'b0;      pc_sel = 1'b0;      
                                                       ir_ld  = 1'b0;
               mw_en   = 1'b0;     rw_en  = 1'b0;      alu_op = 4'b0000;
               {ns_N,ns_Z,ns_C} = {ps_N,ps_Z,ps_C};
               nextstate = FETCH;
               status = {ps_N,ps_Z,ps_C,5'b01100};
          end
          
          //JNE
          // if (ps_Z==0) PC<-PC+SE_IR[7:0] else PC <-PC
          // led patterns= {ps_N,ps_Z,ps_C,5'b01101}
          JNE:      begin
               W_Adr   = 3'b000;   R_Adr  = 3'b000;    S_Adr  = 3'b000;
               adr_sel = 1'b0;     s_sel  = 1'b0;
               pc_ld   = ~ps_Z;    pc_inc = 1'b0;      pc_sel = 1'b0;      
                                                       ir_ld  = 1'b0;
               mw_en   = 1'b0;     rw_en  = 1'b0;      alu_op = 4'b0000;
               {ns_N,ns_Z,ns_C} = {ps_N,ps_Z,ps_C};
               nextstate = FETCH;
               status = {ps_N,ps_Z,ps_C,5'b01101};
          end
          
          //JC 
          // if (ps_C ==1 )PC <- PC + SE_IR[7:0] else PC <- PC
          // led patterns={ps_N,ps_Z,ps_C,5'b01101}
          JC:       begin
               W_Adr   = 3'b000;   R_Adr  = 3'b000;    S_Adr  = 3'b000;
               adr_sel = 1'b0;     s_sel  = 1'b0;
               pc_ld   = ps_C;     pc_inc = 1'b0;      pc_sel = 1'b0;      
                                                       ir_ld  = 1'b0;
               mw_en   = 1'b0;     rw_en  = 1'b0;      alu_op = 4'b0000;
               {ns_N,ns_Z,ns_C} = {ps_N,ps_Z,ps_C};
               nextstate = FETCH;
               status = {ps_N,ps_Z,ps_C,5'b01110};
          end
          
          //JMP
          // PC <- IR[ir(2:0)]
          // led patterns={ps_N,ps_Z,ps_C,5'b01111}
          JMP:      begin
               W_Adr   = 3'b000;   R_Adr  = 3'b000;    S_Adr  = IR[2:0];
               adr_sel = 1'b0;     s_sel  = 1'b0;
               pc_ld   = 1;        pc_inc = 1'b0;      pc_sel = 1'b1;      
                                                       ir_ld  = 1'b0;
               mw_en   = 1'b0;     rw_en  = 1'b0;      alu_op = 4'b0000;
               {ns_N,ns_Z,ns_C} = {ps_N,ps_Z,ps_C};
               nextstate = FETCH;
               status = {ps_N,ps_Z,ps_C,5'b01111};
          end

          //HALT
          // default control word value
          // led pattern={ps_N,ps_Z,ps_C,5'b01011}
          HALT:     begin
               W_Adr   = 3'b000;   R_Adr  = 3'b000;    S_Adr  = 3'b000;
               adr_sel = 1'b0;     s_sel  = 1'b0;
               pc_ld   = 0;        pc_inc = 1'b0;      pc_sel = 1'b0;      
                                                       ir_ld  = 1'b0;
               mw_en   = 1'b0;     rw_en  = 1'b0;      alu_op = 4'b0000;
               {ns_N,ns_Z,ns_C} = 3'h0;									
               nextstate = HALT;
               status = {ps_N,ps_Z,ps_C,5'b01011};
          end
          
          // ILLEGAL_OP
          // Default control word values
          // led pattern = 1111_0000
          ILLEGAL_OP:    begin
               W_Adr   = 3'b000;   R_Adr  = 3'b000;    S_Adr  = 3'b000;
               adr_sel = 1'b0;     s_sel  = 1'b0;
               pc_ld   = 0;        pc_inc = 1'b0;      pc_sel = 1'b0;      
                                                       ir_ld  = 1'b0;
               mw_en   = 1'b0;     rw_en  = 1'b0;      alu_op = 4'b0000;
               {ns_N,ns_Z,ns_C} = {ps_N,ps_Z,ps_C};		
               nextstate = ILLEGAL_OP;
               status = 8'b1111_0000;
          end
     endcase

endmodule

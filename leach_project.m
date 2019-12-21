close all;
clear;
clc;
%%%%%%%%%%%%%%%  Set Patameters
%Field Dimensions in Meters
xm=100;
ym=100;

%Sink coordinate 
sink.x=0.5*xm;
sink.y=0.5*ym;

%Number of Nodes in the Field
n=100;

    %%Energy Values
%inital enerygy of a Node
Eo=2;
%Energy required to run circuity
Eelec=0.00000005;  %units in joules/bit
ETx=0.00000005;%units in joules/bit
ERx=0.00000005;
Eamp=10*0.000000000001;   %units in joules/bit%%EFS

%Data Aggregation Enerygy
EDA=0.00000005;
%Size of data package
k=4000;
p=0.05;
%let set number of cluster 
No=p*n;

%Round of operatin
rnd=0;

%monitor the nodes
operating_nodes=n;
transmission_nodes=0;
temp_val=0;
flag1stdead=0;
dead_nodes=0;

%%%%%%%%%%%%%%%%%%%%%%%  Plotting Wirese Sensor Network

  for i=1:n
      %%set the value for each node
      SensorData(i).id=i;
      SensorData(i).x=rand(1,1)*xm;
      SensorData(i).y=rand(1,1)*ym;
      %setting initial energy Eo
      SensorData(i).E=Eo;
      %Set the type of node(0: for normal node ,1:for advance node)
      SenosrData(i).type=0;
      %inital Each node will be normal node
      SensorData(i).cond=1;
      % node condition(1:node is working ,0:node is not working)
      SensorData(i).rop=0;
      %to count number of node in operational
      SensorData(i).rleft=0;%round left for the node to become cluster head
      SensorData(i).dtch=0;%Distance between node and cluster head
      SensorData(i).dts=0% Distance between node and sink
      SensorData(i).tel=0;%count number of times node became cluseter head
      SensorData(i).rn=0;%round node got elected aas cluster head
      SensorData(i).chid=0;%node id of the cluster head
      
      %%now plot the graph
      hold on;
      figure(1);
      plot(xm,ym,SensorData(i).x,SensorData(i).y,'ob',sink.x,sink.y,'*r');
      title('Wiseless sensor network:leach Routing protocal');
  end

  
  
                        %%%%%%%   Set-up Phase %%%%%%%
                        
%operational phase
%phase 1
   while operating_nodes>0
         
         rnd  %display the current round
         
         t=(p/(1-p*(mod(rnd,1/p))));%%setting up the threshold value
         
         %Re-election Value
         tleft=mod(rnd,1/p);
         
         CLheads=0;
         energy=0; %%Reset the energy consume by the network
         
          %%Cluster Heads Election
              for i=1:n
                  
                  SensorData(i).cluster=0;
                  SensorData(i).role=0;
                  SensorData(i).chid=0;
                    
                  if SensorData(i).rleft>0
                      SensorData(i).rleft=SensorData(i).rleft-1;
                  end
                  
                  if (SensorData(i).E>0 ) && (SensorData(i).rleft==0)
                      generate=rand;
                         if generate<t
                             SensorData(i).type=1;
                             SensorData(i).rn=rnd;
                             SensorData(i).tel=SensorData(i).tel+1;
                             SensorData(i).rleft=1/p-tleft;
                             SensorData(i).dts=sqrt((sink.x-SensorData(i).x)^2 + (sink.y-SensorData(i).y)^2);
                             CLheads=CLheads+1;
                             SensorData(i).cluster=CLheads;
                             CL(CLheads).x=SensorData(i).x;
                             CL(CLheads).y=SensorData(i).y;
                             
                             CL(CLheads).id=i;
                         end
                  end
              end
         
              
              %Fixing the size of "CL" array %
              CL=CL(1:CLheads);
              
              
   %Calculate the distance between node and cluster head
   %phase 2
       
        for i=1:n
            if (SensorData(i).role==0) && (SensorData(i).E>0) && (CLheads>0)
                for m=1:CLheads
                    d(m)=sqrt((CL(m).x-SensorData(i).x)^2 + (CL(m).y-SensorData(i).y)^2);
                end
                d=d(1:CLheads);
                [M,I]=min(d(:));
                [Row,Col]=ind2sub(size(d),I);
                SensorData(i).cluster=Col;
                SensorData(i).dtch=d(Col);
                SensorData(i).chid=CL(Col).id;
            end
        end
        
    %Energy Distributin phase 
    %phase 3
    
       for i=1:n
           if (SensorData(i).cond==1) && (SensorData(i).role==0) && (CLheads>0)
               if SensorData(i).E>0
                   ETx=Eelec*k+Eamp*k*SensorData(i).dtch^2;
                   SensorData(i).E=SensorData(i).E-ETx;
                   energy=energy+ETx;
                   
                if SensorData(SensorData(i).chid).E>0 && SensorData(SensorData(i).chid).cond==1 && SensorData(SensorData(i).chid).type==1
                     ERx=(Eelec+EDA)*k;
                     energy=energy+ERx;
                     SensorData(SensorData(i).chid).E=SensorData(SensorData(i).chid).E-ERx;
                     if SensorData(SensorData(i).chid).E<=0
                         SensorData(SensorData(i).chid).cond=0;
                         SensorData(SensorData(i).chid).rop=rnd;
                         dead_nodes=dead_nodes+1;
                         operating_nodes=operating_nodes-1;
                     end
                end
               end
               
               if SensorData(i).E<=0
                   dead_nodes=dead_nodes+1;
                   operating_nodes=operating_nodes-1;
                   SensorData(i).cond=0;
                   SensorData(i).chid=0;
                   SensorData(i).rop=rnd;
               end
               
           end
       end
       
 %%energy distripation for cluster head nodes
 %phase 4
      for i=1:n
          if (SensorData(i).cond==SensorData(i).type==1)
              if SensorData(i).E>0
                  ETx=(Eelec+EDA)*k+Eamp*k*SensorData(i).dts^2;
                  SensorData(i).E=SensorData(i).E-ETx;
                  energy=energy+ETx;
              end
              if SensorData(i).E<=0
                  dead_nodes=dead_nodes+1;
                  operating_nodes=operating_nodes-1;
                  SensorData(i).cond=0;
                  SensorData(i).rop=rnd;
              end
          end
      end
      
      if operating_nodes<n && temp_val==0
          temp_val=1;
          flag1stdead=rnd;
      end
      
      transmission_nodes=transmission_nodes+1;
      if CLheads==0
          transmission_nodes=transmission_nodes-1;
      end
      
      %Next Round%
      rnd=rnd+1;
      tr(transmission_nodes)=operating_nodes;
      op(rnd)=operating_nodes;
      
      if energy>0
          nrg(transmission_nodes)=energy;
      end
   end

clear all;clc;
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%(PI OR PID) & (best controler || gain || controlers)
algorithm.choiceA= questdlg('Please choose:','select one of Switch','PI Controler','PID controler','PID controler');
algorithm.choiceB= questdlg('Please choose:','select one of Switch','Best Controler without Delay','Best gain for each delay','Best Controlers for each delay','Best Controlers for each delay');
if strcmp(algorithm.choiceB,'Best gain for each delay') || strcmp(algorithm.choiceB,'Best Controlers for each delay')
    prompt = {' determind delays '};
    dlg_title = 'Input data';
    num_lines = 1;
    def = {'0:0.1:0.5'};
    answer=inputdlg(prompt,dlg_title,num_lines,def);
    algorithm.del=str2num(answer{1,:});
    clear answer def num_lines dlg_title prompt
else 
    algorithm.del=0;
end
clear prompt dlg_title num_lines def answer

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GSA setting
prompt = {' Size of Population, PS= ',' Span of Variable,SV= ',' Gravitational constant, G=x1*exp(-time/x2) ',' Number of Major mass, NMM=x1*PS*exp(-time/x2) ',' Time Limit for stoping, TL(s)= ',' limit Number of Movement for stoping, NM= ',' Persent of new Generate, PG=PS*x '}; 
dlg_title = 'Input data';
num_lines = 1;
def = {'100','[0 1]','[30 5]','[.9 20]','50000','50','0.40'};
answer=inputdlg(prompt,dlg_title,num_lines,def);
figure(100)
close figure 100
algorithm.NV =[];%detemind at next step
algorithm.PS =str2num(answer{1,:}); %%variable that show Size of Population
algorithm.SV =str2num(answer{2,:}); %variable that show Span of Variable
algorithm.G  =str2num(answer{3,:}); %by variable G1 & G2 calculate Gravitational constant= algorithm.GT=G1*exp(-t/G2)
algorithm.NMM=str2num(answer{4,:}); %variable that show Number of Major mass =algorithm.NMMT=NMM(1)*exp(-t/NMM(2))+NMM(3)
algorithm.TL =str2num(answer{5,:}); %variable that show Time Limit for stop algorithm
algorithm.NM =str2num(answer{6,:}); %variable that show limit Number of Movement for stop algorithm
algorithm.PG =fix(str2num(answer{7,:})*algorithm.PS); %variable that show number of new generate
clear prompt dlg_title num_lines def answer

% determind NV %%%%%%%%%%%%%%%%%%%%%%%%%
if strcmp(algorithm.choiceA,'PI Controler')
    switch algorithm.choiceB
        case 'Best Controler without Delay'
            algorithm.NV =2;
        case 'Best gain for each delay'
            algorithm.NV =1;
        case 'Best Controlers for each delay'
            algorithm.NV =2;
    end
elseif strcmp(algorithm.choiceA,'PID controler')
    switch algorithm.choiceB
        case 'Best Controler without Delay'
            algorithm.NV =3;
        case 'Best gain for each delay'
            algorithm.NV =1; 
        case 'Best Controlers for each delay'
            algorithm.NV =3;
    end
end

%% start algorithm
for delay=1:length(algorithm.del);
GSAmain.delay=algorithm.del(delay);
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%update in each step
algorithm.counter=0;%showing that number of repeating algorithm
algorithm.time=0;%showing elpased time
algorithm.GT=[];%showing G in each step of algorithm
algorithm.NMMT=[];%showing NMM in each step of algorithm
algorithm.span=[];%max SV- min SV
algorithm.SV2=[];%matrix;show for each variable
algorithm.xyz=[];%matrix PS*NV;showing the coordinate of responses
algorithm.best_xyz=[];%matrix cunter*NV;showing the best of responses in yet
algorithm.FC=[];%vector;  showing the best of Fitness Function
algorithm.best_FC=[];%vector; showing the best of Fitness Function
algorithm.meanFC=[];%vector;showing the mean of Fitness Function
algorithm.stop=[];%this variable determaine that the algorithm starting or stoping

%% Generate initial population
    algorithm.xyz=rand(algorithm.PS,algorithm.NV);
    sizeSV=size(algorithm.SV);
    if   sizeSV(2)==2 %use algorithm.span of variables for all variables
         algorithm.SV2=algorithm.SV;
         algorithm.span=abs(algorithm.SV(2)-algorithm.SV(1));
         algorithm.xyz=algorithm.xyz*algorithm.span+min(algorithm.SV);
    else %any variable has a algorithm.span separate from other variable
         algorithm.SV2=reshape(algorithm.SV,2,algorithm.NV)';
         algorithm.span=abs(algorithm.SV2(:,2)-algorithm.SV2(:,1));
         for  p=1:algorithm.NV
              algorithm.xyz(:,p)=algorithm.xyz(:,p)*algorithm.span(p)+min(algorithm.SV2(p,1),algorithm.SV2(p,2));
         end
    end
clear  p sizeSV      


%% start main algorithm  for each delay
tic%start time
while isempty(algorithm.stop) %if algorithm.stop be empty the algorithm continuance   
    algorithm.counter=algorithm.counter+1;
    display(algorithm.NM-algorithm.counter)
%% make     
    algorithm.time=toc;
    algorithm.GT(algorithm.counter,1)=(algorithm.G(1,1)*exp(-algorithm.counter/algorithm.G(1,2)));
    algorithm.NMMT(algorithm.counter,1)=ceil(algorithm.NMM(1,1)*algorithm.PS*exp(-algorithm.counter/algorithm.NMM(1,2)));
    if algorithm.NMMT(algorithm.counter,1)>algorithm.PS
        algorithm.NMMT(algorithm.counter,1)=algorithm.PS;
    elseif algorithm.NMMT(algorithm.counter,1)<=1
        algorithm.NMMT(algorithm.counter,1)=3;
    end
    

%% check condition for stoping algorithm befor recallig Fitness Function
    switch 1
        case algorithm.time>algorithm.TL;
            algorithm.stop='time end';
        case algorithm.counter>algorithm.NM;
            algorithm.stop='Number of movement end';  
        otherwise

%% send data to Fitness function and receive value of Fitness function
for q=1:algorithm.PS
    if strcmp(algorithm.choiceA,'PI Controler')
                switch algorithm.choiceB
                    case 'Best Controler without Delay'
                        GSAmain.KP=algorithm.xyz(q,1);
                        GSAmain.KI=algorithm.xyz(q,2);
                        GSAmain.KD=0;
                        GSAmain.gain=1;

                    case 'Best gain for each delay'
                        if delay==1 && algorithm.counter==1 && q==1
                            prompt = {' best PI controler without delay'}; 
                            dlg_title = 'Input best PI controler=[Kp+Ki/s] ';
                            num_lines = 1;
                            def = {'[0.095073 0.16718]'};
                            answer=inputdlg(prompt,dlg_title,num_lines,def);
                            par=str2num(answer{1,:});
                            GSAmain.KP=par(1,1);
                            GSAmain.KI=par(1,2);
                            GSAmain.KD=0;
                            clear prompt dlg_title num_lines def answer par
                        end
                        GSAmain.gain=algorithm.xyz(q,1);
                        
                    case 'Best Controlers for each delay'
                        GSAmain.KP=algorithm.xyz(q,1);
                        GSAmain.KI=algorithm.xyz(q,2);
                        GSAmain.KD=0;
                        GSAmain.gain=1;
                end
            elseif strcmp(algorithm.choiceA,'PID controler')
                switch algorithm.choiceB
                    case 'Best Controler without Delay'
                        GSAmain.KP=algorithm.xyz(q,1);
                        GSAmain.KI=algorithm.xyz(q,2);
                        GSAmain.KD=algorithm.xyz(q,3);
                        GSAmain.gain=1;
                
                    case 'Best gain for each delay'
                        if delay==1 && algorithm.counter==1 && q==1
                            prompt = {' best PID controler without delay'}; 
                            dlg_title = 'Input PID best controler [Kp+Ki/s+Kds] ';
                            num_lines = 1;
                            def = {'[0.25732 0.1618 0.01]'};
                            answer=inputdlg(prompt,dlg_title,num_lines,def);
                            par=str2num(answer{1,:});
                            GSAmain.KP=par(1,1);
                            GSAmain.KI=par(1,2);
                            GSAmain.KD=par(1,3);
                            clear prompt dlg_title num_lines def answer par
                        end
                        GSAmain.gain=algorithm.xyz(q,1);
                                    
                    case 'Best Controlers for each delay'
                        GSAmain.KP=algorithm.xyz(q,1);
                        GSAmain.KI=algorithm.xyz(q,2);
                        GSAmain.KD=algorithm.xyz(q,3);
                        GSAmain.gain=1;
                end
    end 
        sim('GSA_System.mdl');
        GSAmain.Performanc(q,1)=sum(sum((abs(results_from_GSA_mdl.signals.values))))/length(results_from_GSA_mdl.signals.values);   
end
           algorithm.FC=GSAmain.Performanc;

%% check receive value of Fitness function after recallig Fitness Function
            if  max(algorithm.FC)==min(algorithm.FC)
                algorithm.stop='max(algorithm.FC)==min(algorithm.FC)'; % stop algorithm   
            else
                
%% storege best responce by best_FC & best_xyz
                   clear MS var1 parr
                   if algorithm.counter==1
                       algorithm.best_FC(algorithm.counter,1)=min(algorithm.FC);
                       algorithm.FC;
                       par=find(algorithm.FC==min(algorithm.FC));
                       minxyz=algorithm.xyz(par(1),:);
                       algorithm.best_xyz(algorithm.counter,:)=minxyz; 
                       clear par minxyz
                   
                   elseif min(algorithm.FC)>algorithm.best_FC(algorithm.counter-1,1)
                       algorithm.best_FC(algorithm.counter,1)=algorithm.best_FC(algorithm.counter-1,1);
                       algorithm.best_xyz(algorithm.counter,:)=algorithm.best_xyz(algorithm.counter-1,:);
                       par=find(algorithm.FC==max(algorithm.FC));
                       algorithm.xyz(par(1),:)=algorithm.best_xyz(algorithm.counter,:);
                       algorithm.FC(par(1),1)=algorithm.best_FC(algorithm.counter,1);
                       clear par 
                   else%if min(algorithm.FC)<=algorithm.best_FC(algorithm.counter-1,:)
                       algorithm.best_FC(algorithm.counter,:)=min(algorithm.FC);
                       par=find(algorithm.FC==min(algorithm.FC));
                       minxyz=algorithm.xyz(par(1),:);
                       algorithm.best_xyz(algorithm.counter,:)=minxyz;
                   end 
                   clear par minxyz
                   
                   algorithm.meanFC(algorithm.counter,1)=mean(algorithm.FC);

%% creat Mass Stars & sortng rsponse by MS

                   ms=((algorithm.FC-max(algorithm.FC))./(-max(algorithm.FC)+min(algorithm.FC)));
                   MS=ms;
                   %MS=((algorithm.PS*ms)/sum(ms))';%the mass of responses
                  
                   %sorting
                   msfcxyz=[MS,algorithm.FC,algorithm.xyz];
                   MSFCxyz=sortrows(msfcxyz,-1);
                   MS=MSFCxyz(:,1);
                   algorithm.FC=MSFCxyz(:,2);
                   algorithm.xyz=MSFCxyz(:,3:end);           
                   clear msfcxyz MSFCxyz ms 
                   %%%outing is MS
%% 13-Calculate distance
                   Dist=squareform(pdist(algorithm.xyz));  
%% 14-moving star                       
                   Randi=rand(algorithm.PS);
                   V=zeros(algorithm.PS,algorithm.NV);
                   apt=[];
                   for  p=1:algorithm.PS
                        ap=zeros(1,algorithm.NV);
                        for  q=1:algorithm.NMMT(algorithm.counter,1)
                             if   p~=q
                                 ap=ap+(algorithm.GT(algorithm.counter,1).*Randi(p,q).*MS(q)./((Dist(p,q)^2+eps))).*(algorithm.xyz(q,:)-algorithm.xyz(p,:));
                             end
                        end 
                        apt=[apt;ap]; %#ok<AGROW>
                        clear ap
                   end
                   V=rand(algorithm.PS,algorithm.NV).*V+apt;
                   algorithm.xyz=algorithm.xyz+V;
                   clear apt ap Randi NMM G q p Dist V 
                   clear MS
%% find xyz that has no correct span  and replace by new stars
                   %finding
                   sizeSV=size(algorithm.SV);
                   if   sizeSV(2)==2 
                        parmin=algorithm.xyz<min(algorithm.SV);
                        parmax=algorithm.xyz>max(algorithm.SV);
                        if algorithm.NV==1
                            nospan_xyz=find(((parmin+parmax)')'~=0);
                        else
                            nospan_xyz=find(sum((parmin+parmax)')'~=0);
                        end         
                   else
                       parmin2=zeros(algorithm.PS,1);
                       parmax2=zeros(algorithm.PS,1);
                        for  p=1:algorithm.NV
                             parmin2=parmin2+double(algorithm.xyz(:,p)<min(algorithm.SV2(p,:)));
                             parmax2=parmax2+double(algorithm.xyz(:,p)>max(algorithm.SV2(p,:)));                                 
                        end
                       nospan_xyz=find(((parmin2+parmax2)')'~=0);
                   end
                   
                   
                   %replacing
                   if ~isempty(nospan_xyz)  
                       par=rand(length(nospan_xyz),algorithm.NV);
                       if   sizeSV(2)==2 %use algorithm.span of variables for all variables
                            par=par*algorithm.span+min(algorithm.SV);
                       else
                           for  p=1:algorithm.NV;
                               par(:,p)=par(:,p)*algorithm.span(p)+min(algorithm.SV2(p,1),algorithm.SV2(p,2));
                           end
                       end
                   algorithm.xyz(nospan_xyz,:)=[];
                   algorithm.xyz=[algorithm.xyz;par];
                   end
                   clear parmin2 parmax2 parmin parmax sizeSV p par
                   %out nospan_xyz 
                   
%% delet the Ms has less mass & make random star for replace with this  
                   if   algorithm.PG>length(nospan_xyz) 
                        par=rand(algorithm.PG,algorithm.NV);
                        sizeSV=size(algorithm.SV);
                        if   sizeSV(2)==2 %use span of variables for all variables
                             par=par*algorithm.span+min(algorithm.SV);
                        else %any variable has a algorithm.span separate from other variable
                             for  p=1:algorithm.NV
                                  par(:,p)=par(:,p)*algorithm.span(p)+min(algorithm.SV2(p,1),algorithm.SV2(p,2));
                             end
                        end
                        algorithm.xyz(algorithm.PS-algorithm.PG+1:algorithm.PS,:)=[];
                        algorithm.xyz=[algorithm.xyz;par];   
                   end
                   clear  p par    sizeSV
                   clear nospan_xyz
         
            end
    end
%% result miany
end
%for each delay
disp(algorithm.stop)
if strcmp(algorithm.choiceA,'PI Controler')
                switch algorithm.choiceB
                    case 'Best Controler without Delay'
                        GSAmain.KP=algorithm.best_xyz(end,1);
                        GSAmain.KI=algorithm.best_xyz(end,2);
%                         GSAmain.KD=0;
%                         GSAmain.gain=1;

                    case 'Best gain for each delay'
%                         GSAmain.KP=1;
%                         GSAmain.KI=1;
%                         GSAmain.KD=0;
                        GSAmain.gain=algorithm.best_xyz(end,1);
                        
                    case 'Best Controlers for each delay'
                        GSAmain.KP=algorithm.best_xyz(end,1);
                        GSAmain.KI=algorithm.best_xyz(end,2);
%                         GSAmain.KD=0;
%                         GSAmain.gain=1;
                end
            elseif strcmp(algorithm.choiceA,'PID controler')
                switch algorithm.choiceB
                    case 'Best Controler without Delay'
                        GSAmain.KP=algorithm.best_xyz(end,1);
                        GSAmain.KI=algorithm.best_xyz(end,2);
                        GSAmain.KD=algorithm.best_xyz(end,3);
%                         GSAmain.gain=1;
                
                    case 'Best gain for each delay'
%                         GSAmain.KP=1;
%                         GSAmain.KI=1;
%                         GSAmain.KD=1;
                        GSAmain.gain=algorithm.best_xyz(end,1);
                                    
                    case 'Best Controlers for each delay'
                        GSAmain.KP=algorithm.best_xyz(end,1);
                        GSAmain.KI=algorithm.best_xyz(end,2);
                        GSAmain.KD=algorithm.best_xyz(end,3);
%                         GSAmain.gain=1;
                end
    end 
sim('GSA_System.mdl');
figure
plot(BestOutput.time,BestOutput.signals.values);
title([algorithm.choiceA  '  ' algorithm.choiceB]);
xlabel(['best xyz: ' num2str(algorithm.best_xyz(end,:)) ' for delay= ' num2str(GSAmain.delay)]);
result{delay}=algorithm;
end
%% final result
load gong.mat;
sound(y, Fs);
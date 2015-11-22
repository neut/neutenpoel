% Neutenpoel script. This progam simulates a model of how a Lichtenberg figure
% is created. The code and model are poorly documented unfortunately. In short:
% 
% The script represents a quantitative model of a dielectric material 'charged'
% with only negative charges. A defect (a neutral charge) is introduced
% somwhere in the domain, which leaves a discharge point form which all charges
% can 'escape'. Next, the model picks a neighbouring charge-containing point at 
% random to travel to that 'hole', creating a path along the way and leaving a 
% second hole. Every time a charge passes an existing path, its weight is 
% increased. This iteration continues until no negative charges remain, leaving 
% a collection of paths, where the path thickness is propertional to the
% 'current' as passed through that path.
%
% ==============================================================================
% Licence:
%   This code is distributed under the GNU General Public Licence.
% 
% Authors:
%   M.W.M. Neut <m.neut@immend.com>
%   E.P. van der Poel <e.p.vanderpoel@immend.com>
%
% Information:
%   This script is in MATLAB syntax and is tested with version 2011a and 2014b
% ==============================================================================

tstart=clock;
Gridsize = 21;

Defectx = 2;
Defecty = ((Gridsize + 1)/2);


Field = zeros(Gridsize);
Field(Defectx,Defecty) = 1;

% lines=[Defectx-1 Defectx Defecty Defecty];
lines = [];

while min(min(Field(2:(Gridsize-1),2:(Gridsize-1)))) == 0
        
    flagg = 0;
    while flagg == 0

            xt = ceil(rand * (Gridsize-2)) + 1;
            yt = ceil(rand * (Gridsize-2)) + 1;

                

        Sectorx = [xt - 1; xt; xt + 1; xt];
        Sectory = [yt; yt - 1; yt; yt + 1];       
            if Field(xt,yt) == 0
                for i=1:4
                    if Field(Sectorx(i),Sectory(i)) >= 1
                        flagg = 1;
                        break
                    end
                end
            end
    end
    
    Sectorval = zeros(4,1);
    for j=1:4
       Sectorval(j) = Field(Sectorx(j), Sectory(j));
    end

                        [P,I] = max(Sectorval);

                        if size(P) > 1 
                            if sqrt(Sectorx(I(1)-2)^2 + (Sectory(I(1))-((Gridsize + 1)/2))^2) > sqrt(Sectorx(I(2)-2)^2 + (Sectory(I(2))-((Gridsize + 1)/2))^2)
                                I = I(2);
                            elseif sqrt(Sectorx(I(1)-2)^2 + (Sectory(I(1))-((Gridsize + 1)/2))^2) < sqrt(Sectorx(I(2)-2)^2 + (Sectory(I(2))-((Gridsize + 1)/2))^2)
                                I = I(1);
                            else
                                I = I(ceil(rand * 2));
                            end
                        end                      

                        Field(xt,yt) = Field(xt,yt) + 1;
                        
                        if xt*yt > Sectorx(I)*Sectory(I)
                            lines = [lines; Sectorx(I) xt Sectory(I) yt];
                        end

                        if xt*yt < Sectorx(I)*Sectory(I)
                            lines = [lines; xt Sectorx(I) yt Sectory(I)];
                        end  
                        
                        xt = Sectorx(I);
                        yt = Sectory(I);
                        lines=unique(lines,'rows');

        


            while 1
                if xt == Defectx && yt == Defecty
                    Field(Defectx,Defecty) = Field(Defectx,Defecty) + 1;
                    break
                end
                

                Sectorx = [xt - 1; xt; xt + 1; xt];
                Sectory = [yt; yt - 1; yt; yt + 1];
                clear Sectorval
                Found=[];
                switch I
                    case 1
                        I = 3;
                    case 2
                        I = 4;
                    case 3
                        I = 1;
                    case 4
                        I = 2;
                end
                
                        for j=1:4
                            if j ~= I
                                if xt*yt > Sectorx(j)*Sectory(j)                                     
                                     for i=1:size(lines,1)                                          
                                         if [Sectorx(j) xt Sectory(j) yt] == lines(i,1:4)
                                            Found = [Found; Sectorx(j) xt Sectory(j) yt Field(Sectorx(j),Sectory(j)) j 1];
                                            break
                                         end
                                     end
                                end

                                if xt*yt < Sectorx(j)*Sectory(j)
                                     for i=1:size(lines,1)                                         
                                        if [xt Sectorx(j) yt Sectory(j)] == lines(i,1:4)
                                            Found = [Found; xt Sectorx(j) yt Sectory(j) Field(Sectorx(j),Sectory(j)) j 2];
                                            break
                                        end
                                     end
                                end
                            end                            
                        end
                if size(Found,1) > 0
                    [M N] = max(Found(:,5));
                    if size(N) > 1
                        switch ceil(rand*2)
                            case 1
                                Found = Found(1,:);
                                N = N(1);
                            case 2
                                Found = Found(2,:);
                                N = N(2);
                        end
                    end
                    Field(xt,yt) = Field(xt,yt) + 1;
                    I = Found(N,6);
                    if Found(N,7) == 1
                         lines = [lines; Found(N,1) xt Found(N,3) yt];
                         xt = Found(N,1);
                         yt = Found(N,3);
                    end
                    if Found(N,7) == 2
                         lines = [lines; xt Found(N,2) yt Found(N,4)];
                         xt = Found(N,2);
                         yt = Found(N,4);                     
                    end
                end
            end
            disp((Gridsize-2)^2 - Field(Defectx,Defecty))
end

figure(1);set(1,'Position',[220 220 600 600]);hold on;


MaxLineTh=max([Field(Defectx,Defecty+1) Field(Defectx,Defecty-1) Field(Defectx+1,Defecty) Field(Defectx-1,Defecty)]);

%tmpvar = zeros(1,size(lines,1));

DrawThreshold = 3;

for i = 1 : size(lines,1)    
    min([Field(lines(i,1),lines(i,3)) Field(lines(i,2),lines(i,4))]);
    LT = min([Field(lines(i,1),lines(i,3)) Field(lines(i,2),lines(i,4))])/(2*MaxLineTh);
    %tmpvar(i) = LT;
    
    if LT > DrawThreshold*(1 / (2*MaxLineTh))
        if lines(i,1) == lines(i,2)        
            fill([(lines(i,1)-LT) (lines(i,2)-LT) (lines(i,1)+LT) (lines(i,2)+LT)],[lines(i,3) lines(i,4) lines(i,4) lines(i,3)],'k');
        elseif lines(i,3) == lines(i,4)
            fill([lines(i,1) lines(i,2) lines(i,2) lines(i,1)],[(lines(i,3) + LT) (lines(i,4) + LT) (lines(i,4) - LT) (lines(i,3) - LT)],'k');
        end
    end
end

figure(2);
lullo = [];
for i = 1 : size(lines,1)    
    min([Field(lines(i,1),lines(i,3)) Field(lines(i,2),lines(i,4))]);
    LT = min([Field(lines(i,1),lines(i,3)) Field(lines(i,2),lines(i,4))])/MaxLineTh;
    lullo = [lullo;LT];
    if LT > DrawThreshold*(20 / MaxLineTh)
        line([lines(i,1) lines(i,2)],[lines(i,3) lines(i,4)],'LineWidth',(LT*20));

    end
end

% Written by M.W.M. Neut & E.P. van der Poel
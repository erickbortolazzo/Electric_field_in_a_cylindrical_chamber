%Este programa determina o m�dulo normalizado do campo el�trico dentro de
%uma c�mara cil�ndrica devido a DOIS pares de eletrodos.
%Destaca ainda a �rea onde a varia��o do m�dulo e �ngulo � <1% e 1�.

%Dois canais, ou pares de eletetrodos est�o dispon�veis.
%CANAL 1: -90� e +90� (eixo y cartesiano)
%CANAL 2: (-90+Rot)� e (90+Rot)�, onde 'Rot' � definido pelo usu�rio. 

%Usu�rio deve informar a dire��o resultante do est�mulo desejado
%Informar a dire��o em rela��o ao �ngulo de 90�
%Alterar a vari�vel 'Posicao',  
%Ou seja, se 'Posicao=0', a dire��o resultante ser� 90� (EIXO Y cartesiano)

%C�lculo relativo das componentes do E resultante nos eixos cartesianos
Rot=90;		%MODIFICAR: Defasagem entre canais
Posicao=0; 	%MODIFICAR: Dire��o resultante desejada (em rel_ 90�)
ay=sind(Posicao+90);	%componente ay do pulso resultante
ax=cosd(Posicao+90);	%componente ax do pulso resultante 

%C�lculo da intensidade do est�mulo em cada canal 
CH2=-1/sind(Rot)*ax;CH2(abs(CH2)<0.0001)=0;		%toda componente ax � devido apenas ao canal 2
CH1=(ay)-CH2*cosd(Rot); CH1(abs(CH1)<0.0001)=0;

%Malha XY e regi�o delimitada pela c�mara
clear
[r,theta] = meshgrid(0:.001:1,(-pi:pi/500:pi));
[x,y] = pol2cart(theta,r);

%C�lculo das componentes E para um �nico Par de Eletrodo [0 1]
k=1; %2I/pi sigma h 
b=1;
k1= b./(   (r.^2+b.^2+2*r*b.*sin(theta)).*(r.^2+b.^2-2*r*b.*sin(theta))       );
ER1= k1.*sin(theta).*(b.^2-r.^2);
ET1= k1.*cos(theta).*(b.^2+r.^2);

%Calculo das componentes E para o segundo Par de Eltrodo a 60� [-0.8660 0.5]
[dimensao,m]=size(theta);

Desplaz=round(Rot*dimensao/360);   %rot/(360/n)
ER2=circshift(ER1,[Desplaz 0]); 
ET2=circshift(ET1,[Desplaz 0]); 

%Soma vetorial dos campos E
ER=ER1*CH1+ER2*CH2;
ET=ET1*CH1+ET2*CH2;

%Intensidade Resultante
Norma=(ER.^2+ET.^2).^(1/2);
Norma(Norma>6)=6;

%gr�fico em cores da intensidade de E
figure()
surf(x,y,Norma,'EdgeColor','None','facecolor', 'flat','DisplayName',' ');
legend('-DynamicLegend');
%colormap(winter);
%bar=colorbar('SouthOutside');
%title(bar,'E dentro da C�mara Normalizado com E(0,0)');
hold on

%Regi�o cujo m�dulo varia menos que 1%
AreaModulo=Norma;
AreaModulo(Norma<0.99)=nan;
AreaModulo(Norma>1.01)=nan;
surf(x,y,AreaModulo,'EdgeColor','red','facecolor', 'red','DisplayName','%M�dulo<1%');
legend('-DynamicLegend');

%Regi�o cuja fase varia menos que 1�
thetacart=theta*180/pi -90 + atan2d(ET,ER);
AreaFase=Norma;
%AreaFase(abs(thetacart-Posicao)>(1))=nan;
AreaFase((abs(thetacart-Posicao)>(1))&(abs(thetacart-Posicao)<(359)))=nan;
AreaFase(abs(thetacart-Posicao)>(361)&(abs(thetacart-Posicao)<(719)))=nan;
AreaFase(abs(thetacart-Posicao)>(721))=nan;
surf(x,y,AreaFase,'EdgeColor','green','facecolor', 'green','DisplayName','%Fase<1�')
legend('-DynamicLegend');

%Regi�o de trabalho: intersec��o das duas �rea anteriores
AreaUtil=(abs(AreaModulo.*AreaFase)).^0.5;
surf(x,y,AreaUtil,'EdgeColor','white','facecolor', 'white','DisplayName','%M�dulo<1% e Fase<1�')
legend('-DynamicLegend');

%Circulo delimitado de 10% do raio
AreaRaio=Norma;
AreaRaio(r<0.09)=nan;
AreaRaio(r>0.11)=nan;
surf(x,y,AreaRaio,'EdgeColor','black','facecolor', 'black','DisplayName','%Raio 10%�')
legend('-DynamicLegend');

%Par�metros
title(['E - ' num2str(Posicao) '�']);
xlabel('[x] % de r');
ylabel('[y] % de r');
zlabel('M�dulo do E em rela��o ao centro');
axis('square');
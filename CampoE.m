%Este programa determina o módulo normalizado do campo elétrico dentro de
%uma câmara cilíndrica devido a DOIS pares de eletrodos.
%Destaca ainda a área onde a variação do módulo e ângulo é <1% e 1º.

%Dois canais, ou pares de eletetrodos estão disponíveis.
%CANAL 1: -90º e +90º (eixo y cartesiano)
%CANAL 2: (-90+Rot)º e (90+Rot)º, onde 'Rot' é definido pelo usuário. 

%Usuário deve informar a direção resultante do estímulo desejado
%Informar a direção em relação ao ângulo de 90º
%Alterar a variável 'Posicao',  
%Ou seja, se 'Posicao=0', a direção resultante será 90º (EIXO Y cartesiano)

%Cálculo relativo das componentes do E resultante nos eixos cartesianos
clear
Rot=90;		%MODIFICAR: Defasagem entre canais
Posicao=0; 	%MODIFICAR: Direção resultante desejada (em rel_ 90º)
ay=sind(Posicao+90);	%componente ay do pulso resultante
ax=cosd(Posicao+90);	%componente ax do pulso resultante 

%Cálculo da intensidade do estímulo em cada canal 
CH2=-1/sind(Rot)*ax;CH2(abs(CH2)<0.0001)=0;		%toda componente ax é devido apenas ao canal 2
CH1=(ay)-CH2*cosd(Rot); CH1(abs(CH1)<0.0001)=0;

%Malha XY e região delimitada pela câmara
[r,theta] = meshgrid(0:.001:1,(-pi:pi/500:pi));
[x,y] = pol2cart(theta,r);

%Cálculo das componentes E para um único Par de Eletrodo [0 1]
k=1; %2I/pi sigma h 
b=1;
k1= b./(   (r.^2+b.^2+2*r*b.*sin(theta)).*(r.^2+b.^2-2*r*b.*sin(theta))       );
ER1= k1.*sin(theta).*(b.^2-r.^2);
ET1= k1.*cos(theta).*(b.^2+r.^2);

%Calculo das componentes E para o segundo Par de Eltrodo a 60º [-0.8660 0.5]
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

%gráfico em cores da intensidade de E
figure()
surf(x,y,Norma,'EdgeColor','None','facecolor', 'flat','DisplayName',' ');
legend('-DynamicLegend');
%colormap(winter);
%bar=colorbar('SouthOutside');
%title(bar,'E dentro da Câmara Normalizado com E(0,0)');
hold on

%Região cujo módulo varia menos que 1%
AreaModulo=Norma;
AreaModulo(Norma<0.99)=nan;
AreaModulo(Norma>1.01)=nan;
surf(x,y,AreaModulo,'EdgeColor','red','facecolor', 'red','DisplayName','%Módulo<1%');
legend('-DynamicLegend');

%Região cuja fase varia menos que 1º
thetacart=theta*180/pi -90 + atan2d(ET,ER);
AreaFase=Norma;
%AreaFase(abs(thetacart-Posicao)>(1))=nan;
AreaFase((abs(thetacart-Posicao)>(1))&(abs(thetacart-Posicao)<(359)))=nan;
AreaFase(abs(thetacart-Posicao)>(361)&(abs(thetacart-Posicao)<(719)))=nan;
AreaFase(abs(thetacart-Posicao)>(721))=nan;
surf(x,y,AreaFase,'EdgeColor','green','facecolor', 'green','DisplayName','%Fase<1º')
legend('-DynamicLegend');

%Região de trabalho: intersecção das duas área anteriores
AreaUtil=(abs(AreaModulo.*AreaFase)).^0.5;
surf(x,y,AreaUtil,'EdgeColor','white','facecolor', 'white','DisplayName','%Módulo<1% e Fase<1º')
legend('-DynamicLegend');

%Circulo delimitado de 10% do raio
AreaRaio=Norma;
AreaRaio(r<0.09)=nan;
AreaRaio(r>0.11)=nan;
surf(x,y,AreaRaio,'EdgeColor','black','facecolor', 'black','DisplayName','%Raio 10%º')
legend('-DynamicLegend');

%Parâmetros
title(['E - ' num2str(Posicao) 'º']);
xlabel('[x] % de r');
ylabel('[y] % de r');
zlabel('Módulo do E em relação ao centro');
axis('square');

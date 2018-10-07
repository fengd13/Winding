line_d=50;%线的透明度
re_size=300;%生成图片的大小
port_number=100;%端点的个数
aaa=double(imresize(rgb2gray(imread('b.jpg')),[re_size,re_size]));
ref=double(imresize(rgb2gray(imread('c.jpg')),[re_size,re_size]));
result=(ones(re_size,re_size)*255);
center=[re_size/2,re_size/2];
port_posion_list=int32(zeros(port_number,2));%钉子的位置列表 这里直接选择了均匀圆周分布 如果手动地在五官特征点位置设置几个钉子效果会更好
e=2*pi/port_number;
seita=0;
r=re_size/2-1;
maxloss=11;
resultlist=zeros(2,10000);
for i=1:port_number
        port_posion_list(i,:)=[int32(center(1)+r*sin(seita)),int32(center(2)+r*cos(seita))];
        result(port_posion_list(i,1),port_posion_list(i,2))=0;
        seita=seita+e;
end

step=0;
    while(maxloss>0.65)
        gain_list=zeros(1,port_number^2);
    for i=1:port_number^2
        a=int32(i/port_number);
        b=mod(i,port_number);
        if a>=b
            continue;
        end
        x1=port_posion_list(a+1,1);
        y1=port_posion_list(a+1,2);
        x0=port_posion_list(b+1,1);
        y0=port_posion_list(b+1,2);
        gain_list(i)=lossline(result,aaa,x1,y1,x0,y0,line_d,ref);
    end
    [maxloss, bindex]=max(gain_list);
    a=int32(bindex/port_number);
    b=mod(bindex,port_number);
    step=step+1;
    if step>10000
        break
    end
   resultlist(1,step)=a;
   resultlist(2,step)=b;
   
    x1=port_posion_list(a+1,1);
    y1=port_posion_list(a+1,2);
    x0=port_posion_list(b+1,1);
    y0=port_posion_list(b+1,2);

   
   result=drawline(result,x1,y1,x0,y0,line_d);
   imshow(uint8(result))
    end



%计算每一根线的增益 即在结果图上如果添加该条直线后 是否更接近原图  
%刚开始做的时候发现五官显示不清楚 为了优化五官显示 加入ref项 强化五官部分的权重
%如果在五官特征点处设置了钉子则可以免去这一步
function gain=lossline(result,origin,x1,y1,x0,y0,line_d,ref)
if x1<1 || x0<1 ||y1<1 ||y0<1
    gain=0;
    return ;
end
dx = abs(x1 - x0);
dy = abs(y1 - y0);
if dx>dy
    err=int32(dx/2);
else
    err=int32((0-dy)/2);
end
sx=int32(x0<x1)*2-1;
sy=int32(y0<y1)*2-1;
num=0;
sss=0;
while x0~=x1 || y0~=y1
   num=num+1;
   if abs(result(x0,y0)-line_d-origin(x0,y0))<abs(result(x0,y0)-origin(x0,y0))
       sss=sss+1;
       if result(x0,y0)-line_d<origin(x0,y0)
           sss=sss-abs(result(x0,y0)-line_d-origin(x0,y0))/100;%对占用白色加一点处罚 使得结果不至于太黑
       end
       if ref(x0,y0)<100
          sss=sss+(255-ref(x0,y0))/50;%强化五官的权重
       end
   end

    e2=err;
    if e2>-dx
        err=err-dy;x0=x0+sx;
    end
    if e2<dy
        err=err+(dx);
        y0=y0+sy;
    end
end

gain=sss/num;
    
end

%画直线 Bresenham 直线算法
function re_img=drawline(pic,x1,y1,x0,y0,line_d)
if x1<1 || x0<1 ||y1<1 ||y0<1
    re_img=pic;
    return ;
end

dx = abs(x1 - x0);
dy = abs(y1 - y0);
if dx>dy
    err=int32(dx/2);
else
    err=int32((0-dy)/2);
end
sx=int32(x0<x1)*2-1;
sy=int32(y0<y1)*2-1;
while x0~=x1 || y0~=y1
    if pic(x0,y0)>line_d
    pic(x0,y0)=pic(x0,y0)-line_d;
    else
        pic(x0,y0)=0;
    end
    e2=err;
    if e2>-dx
        err=err-dy;x0=x0+sx;
    end
    if e2<dy
        err=err+dx;
        y0=y0+sy;
    end
end
    
re_img=pic;
    

    
end



% Inclass16

%The folder in this repository contains code implementing a Tracking
%algorithm to match cells (or anything else) between successive frames. 
% It is an implemenation of the algorithm described in this paper: 
%
% Sbalzarini IF, Koumoutsakos P (2005) Feature point tracking and trajectory analysis 
% for video imaging in cell biology. J Struct Biol 151:182?195.
%
%The main function for the code is called MatchFrames.m and it takes three
%arguments: 
%
% 1. A cell array of data called peaks. Each entry of peaks is data for a
% different time point. Each row in this data should be a different object
% (i.e. a cell) and the columns should be x-coordinate, y-coordinate,
% object area, tracking index, fluorescence intensities (could be multiple
% columns). The tracking index can be initialized to -1 in every row. It will
% be filled in by MatchFrames so that its value gives the row where the
% data on the same cell can be found in the next frame. 
%2. a frame number (frame). The function will fill in the 4th column of the
% array in peaks{frame-1} with the row number of the corresponding cell in
% peaks{frame} as described above.
%3. A single parameter for the matching (L). In the current implementation of the algorithm, 
% the meaning of this parameter is that objects further than L pixels apart will never be matched. 

% Continue working with the nfkb movie you worked with in hw4. 

% Part 1. Use the first 2 frames of the movie. Segment them any way you
% like and fill the peaks cell array as described above so that each of the two cells 
% has 6 column matrix with x,y,area,-1,chan1 intensity, chan 2 intensity

% Part 2. Run match frames on this peaks array. ensure that it has filled
% the entries in peaks as described above. 

% Part 3. Display the image from the second frame. For each cell that was
% matched, plot its position in frame 2 with a blue square, its position in
% frame 1 with a red star, and connect these two with a green line. 

reader=bfGetReader('nfkb_movie1.tif');
z=1; c=1; t=reader.getSizeT;
indx=reader.getIndex(z-1,c-1,t-19)+1;
imgt1=bfGetPlane(reader,indx);
indx=reader.getIndex(z-1,c-1,t-18)+1;
imgt2=bfGetPlane(reader,indx);

figure(2); imshow(imgt1,[]);
figure(3); imshow(imgt2,[]);

lims=[100 2000];
figure (4);
subplot(1,2,1); imshow(imgt1,lims);
subplot(1,2,2); imshow(imgt2,lims);

figure(5); imshowpair(imadjust(imgt1),imadjust(imgt2));

imwrite(imgt1,'Imgt1.tif');
imwrite(imgt2,'Imgt2.tif');

seg1=h5read('Imgt1_Simple Segmentation.h5', '/exported_data');
seg2=h5read('Imgt2_Simple Segmentation.h5', '/exported_data'); %it will come out x y inverted 

maskt1=squeeze(seg1==2);    maskc2t1=squeeze(seg1==1);
maskt2=squeeze(seg2==2);    maskc2t2=squeeze(seg2==1);

figure (6); imshowpair(maskt1,maskt2);

stats=regionprops(maskt1,'Area');   
figure (7); hist([stats.Area]);    

minarea=500;
maskt1=imfill(maskt1,'holes');         
maskt1=bwareaopen(maskt1,minarea);
maskt2=imfill(maskt2,'holes');
maskt2=bwareaopen(maskt2,minarea);

figure (8); imshowpair(maskt1,maskt2);

statst1=regionprops(maskt1,imgt1,'Centroid','Area','MeanIntensity');
statst2=regionprops(maskt2,imgt2,'Centroid','Area','MeanIntensity');

statsc2t1=regionprops(maskc2t1,imgt1,'Centroid','Area','MeanIntensity');
statsc2t2=regionprops(maskc2t2,imgt2,'Centroid','Area','MeanIntensity');

xy1=cat(1,statst1.Centroid);
a1=cat(1,statst1.Area);
mi1=cat(1,statst1.MeanIntensity);
tmp=-1*ones(size(a1));
c2i1=cat(1,statsc2t1.MeanIntensity);
%1
peaks{1}=[xy1,a1,tmp,mi1];

xy2=cat(1,statst2.Centroid);
a2=cat(1,statst2.Area);
mi2=cat(1,statst2.MeanIntensity);
tmp=-1*ones(size(a2));
c2i2=[statsc2t2.MeanIntensity];
%1
peaks{2}=[xy2,a2,tmp,mi2];

%1
figure (9); imshow(imgt1',lims); hold on;
plot(peaks{1}(:,1),peaks{1}(:,2),'r*','MarkerSize',18);
plot(peaks{2}(:,1),peaks{2}(:,2),'cs','MarkerSize',18);

%2
peaksmatched=MatchFrames(peaks,2,50);

unmatched=sum(peaksmatched{1}(:,4)==1);

%3
figure(10); imshow(imgt1',lims); hold on;
for ii=1:size(peaks{1})
    text(peaks{1}(ii,1),peaks{1}(ii,2),int2str(ii),'Color','r','FontSize',18);
    nextind=peaksmatched{1}(ii,4);
    if nextind>0
        text(peaks{2}(nextind,1),peaks{2}(nextind,2),int2str(ii),'Color','c','FontSize',18);
    end
end




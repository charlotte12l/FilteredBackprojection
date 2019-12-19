#include <opencv2/core/core.hpp>
#include <opencv2/imgproc/imgproc.hpp>
#include <opencv2/highgui/highgui.hpp>
#define _USE_MATH_DEFINES
#include<iostream>
#include<math.h>
using namespace cv;
using namespace std;


Mat iradon(Mat& filtimg)
{
	Mat fbp = Mat::zeros(filtimg.size().height, filtimg.size().height, CV_32FC1);
	float m, new_theta;
	int i, j, n;
	new_theta = M_PI / filtimg.size().width;
	cout << filtimg.size().width;
	for (n = 0; n<filtimg.size().width; n++)
    {
	for (i = 0; i<fbp.size().height; i++)
	{
		for (j = 0; j<fbp.size().width; j++)
		{
            m = ((j - 0.5*fbp.size().width)*cos(new_theta*n) + (i- 0.5*fbp.size().height)*sin(new_theta*n) + 0.5*filtimg.size().height);
            if ((m>0) && (m<filtimg.size().height))
                //��ֵ
                fbp.at<float>(i, j) += (floor(m)+1-m)*filtimg.at<float>(floor(m), n)+(m-floor(m))*filtimg.at<float>(floor(m)+1, n);
        }
	}
    }
	flip (fbp, fbp,0);
	return fbp;
}


int main()
{
    Mat img = imread("Shepp_Logan.jpg",0);

    Mat P = img.clone();
    P.convertTo(P,CV_32FC1);//32λ���� ��ͨ��
    normalize(P, P, 0, 1, NORM_MINMAX, CV_32F);

    int angle=360;//�Ƕȵ���Ŀ
    Mat radon_image = Mat(P.rows,angle,CV_32FC1);
    int center = P.rows/2;

    float shift0[] = {  1, 0, -float(center),
                        0, 1, -float(center),
                        0, 0, 1};
    float shift1[] = {  1, 0, float(center),
                        0, 1, float(center),
                        0, 0, 1};
    Mat m0 = Mat(3,3,CV_32FC1,shift0);
    Mat m1 = Mat(3,3,CV_32FC1,shift1);
    float *theta = new float[angle];//��ת�Ƕ�
    //����ͶӰ
    for(int t=0;t<angle;t++)
    {
        theta[t]=t*CV_PI/angle;
        float R[] = {cos(theta[t]), sin(theta[t]), 0,
                     -sin(theta[t]), cos(theta[t]), 0,
                     0, 0, 1};
        Mat mR = Mat(3,3,CV_32FC1,R);
        Mat rotation = m1*mR*m0;
        Mat rotated;
        warpPerspective(P,rotated,rotation,Size(P.rows,P.cols),WARP_INVERSE_MAP);
        for(int j=0;j<rotated.cols;j++)
        {
            float *p1 = radon_image.ptr<float>(j);
            for(int i=0;i<rotated.rows;i++)
            {
                float *p2 = rotated.ptr<float>(i);
                p1[t] += p2[j];
            }
        }
    }



    Mat radon_image_norm;
    normalize(radon_image,radon_image_norm,0,1,CV_MINMAX);
    imshow("My Radon Transform",radon_image_norm);
    cout<<"Radon Succeed"<<endl;
    waitKey();

     //�õ�DFT����ѳߴ磬�Լ��ټ���
    Mat paddedImg, paddedImg_norm;
    int m = getOptimalDFTSize(radon_image.rows);
    int n = getOptimalDFTSize(radon_image.cols);


    cout << "ͼƬԭʼ�ߴ�Ϊ��" << radon_image.cols << "*" << radon_image.rows <<endl;
    cout << "DFT��ѳߴ�Ϊ��" << n << "*" << m <<endl;

    //���ͼ��
    copyMakeBorder(radon_image, paddedImg, 0, m - radon_image.rows,
                   0, n - radon_image.cols, BORDER_CONSTANT, Scalar::all(0));
    normalize(paddedImg,paddedImg_norm,0,1,CV_MINMAX);
    imshow("padded",paddedImg_norm);
    waitKey();

    transpose(paddedImg,paddedImg);
    //������ͼ�����һ�������Ķ�ά���飨����ͨ����Mat��������DFT
    Mat matArray[] = {Mat_<float>(paddedImg), Mat::zeros(paddedImg.size(), CV_32F)};//���㣬һ��ʵ����һ���鲿
    Mat complexInput, complexOutput;
    merge(matArray, 2, complexInput);//�ںϺ����dft

    //����Ҷ�任
    dft(complexInput, complexOutput,DFT_ROWS|DFT_COMPLEX_OUTPUT,0);
    cout<<"dft done"<<endl;
    split(complexOutput,matArray);

    //ʹ��R-L�������˲�
    float M = matArray[1].size().width - 1;
    for (int i = 0; i<matArray[0].size().height;i++)
    {
        for (int j = 0; j<matArray[0].size().width;j++)
        {
            matArray[0].at<float>(i,j) *= (1-abs((j-M/2)/M)*2);
            matArray[1].at<float>(i,j) *= (1-abs((j-M/2)/M)*2);
        }
    }
    merge(matArray,2,complexOutput);
    Mat filteredimg;
    //����Ҷ���任
    dft(complexOutput,filteredimg, DFT_INVERSE|DFT_ROWS|DFT_REAL_OUTPUT);
    transpose(filteredimg,filteredimg);
    //��ʾͶӰ���
    imshow("FILTERED:",filteredimg);
    cout<<"filtered img size:"<<filteredimg.size()<<endl;


    cout<<"filtering done"<<endl;
    waitKey();

    Mat fbp;
    fbp = Mat::zeros(P.size(),CV_32FC1);



    //��ͶӰ
	fbp = iradon(filteredimg);


	normalize(fbp, fbp, 0, 1, NORM_MINMAX, CV_32F);
    cout<<"fbp done"<<endl;
    imshow("FBP:",fbp);


    waitKey();
    destroyAllWindows();
}

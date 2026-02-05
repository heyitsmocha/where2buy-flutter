import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:w2b_flutter/models/inquiry_model.dart';

part 'api_util.g.dart';

@RestApi(baseUrl: "http://192.168.0.81:8000/api")
abstract class ApiService {
  factory ApiService(Dio dio, {String baseUrl}) = _ApiService;

  @GET("/inquiries")
  Future<List<Inquiry>> getInquiries(
    @Query('latitude') double latitude,
    @Query('longitude') double longitude,
  );

  @POST("/inquiries")
  Future<Inquiry> createInquiry(@Body() Inquiry inquiry);

  @GET("/inquiries/{id}")
  Future<Inquiry> getInquiryById(@Path("id") int id);

  @DELETE("/inquiries/{id}")
  Future<void> deleteInquiry(@Path("id") int id);
}
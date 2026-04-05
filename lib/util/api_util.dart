import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:w2b_flutter/models/answer_model.dart';
import 'package:w2b_flutter/models/inquiry_model.dart';
import 'package:w2b_flutter/models/user_model.dart';

part 'api_util.g.dart';

const String baseUrl = "http://192.168.0.81:8000/api";

@RestApi(baseUrl: baseUrl)
abstract class ApiService {
  factory ApiService(Dio dio, {String baseUrl}) = _ApiService;

  @GET("/search_suggestions")
  Future<List<String>> getSearchSuggestions({
    @Query('query') required String query,
    @CancelRequest() required CancelToken cancelToken,
  });

  @POST("/login")
  Future<UserResponse> login({
    @Query('email') required String email,
    @Query('password') required String password,
    @Query('device_name') required String deviceName,
  });

  @POST("/logout")
  @Extra({"requiresAuth": true})
  Future<HttpResponse<void>> logout();
}

@RestApi(baseUrl: "$baseUrl/inquiries")
abstract class InquiryApiService {
  factory InquiryApiService(Dio dio, {String baseUrl}) = _InquiryApiService;

  @GET("/")
  Future<List<Inquiry>> getInquiries(
    @Query('latitude') double latitude,
    @Query('longitude') double longitude,
  );

  @GET("/{id}")
  Future<Inquiry> getInquiryById(@Path("id") int id);

  @POST("/")
  @Extra({"requiresAuth": true})
  @MultiPart()
  Future<Inquiry> createInquiry({
    @Body() required FormData data,
  });

  @PUT("/{id}")
  @Extra({"requiresAuth": true})
  @MultiPart()
  Future<Inquiry> updateInquiry({
    @Path("id") required int id,
    @Body() required FormData data,
  });

  @DELETE("/{id}")
  @Extra({"requiresAuth": true})
  Future<void> deleteInquiry(@Path("id") int id);

  @GET("/me")
  @Extra({"requiresAuth": true})
  Future<List<Inquiry>> getMyInquiries();
}

@RestApi(baseUrl: "$baseUrl/answers")
abstract class AnswerApiService {
  factory AnswerApiService(Dio dio, {String baseUrl}) = _AnswerApiService;

  // @GET("/")
  // Future<List<Answer>> getAnswersByInquiryId(@Query('inquiry_id') int inquiryId);

  @GET("/{id}")
  Future<List<Answer>> getNearbyAnswers({
    @Query('id') required int id,
    @Query('query') required String query,
    @Query('latitude') required double latitude,
    @Query('longitude') required double longitude,
    @Query('radius_meters') required double radiusMeters,
  });

  @POST("/")
  @Extra({"requiresAuth": true})
  @MultiPart()
  Future<Answer> createAnswer({
    @Body() required FormData data,
  });

  @PUT("/{id}")
  @Extra({"requiresAuth": true})
  @MultiPart()
  Future<Answer> updateAnswer({
    @Path("id") required int id,
    @Body() required FormData data,
  });

  @DELETE("/{id}")
  @Extra({"requiresAuth": true})
  Future<void> deleteAnswer(@Path("id") int id);

  @GET("/me")
  @Extra({"requiresAuth": true})
  Future<List<Answer>> getMyAnswers();
}

abstract class UserApiService {

}
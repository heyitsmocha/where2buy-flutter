import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:w2b_flutter/models/answer_model.dart';
import 'package:w2b_flutter/models/inquiry_model.dart';
import 'package:w2b_flutter/models/item_model.dart';
import 'package:w2b_flutter/models/response_model.dart';
import 'package:w2b_flutter/models/user_model.dart';

part 'api_util.g.dart';

class ApiUtil {
  /// A helper method to safely call API methods and handle errors in a consistent way
  static Future<T> safeApiCall<T>({
    required Future<T> Function() onTry,
    required Function(Exception exception) onError,
    required Function(DioException e) onDioError,
    Function()? onFinally
  }) async {
    try {
      return await onTry();
    } on DioException catch (e) {
      onDioError(e);
      rethrow;
    } on Exception catch (e) {
      onError(e);
      rethrow;
    } finally {
      if (onFinally != null) {
        onFinally();
      }
    }
  }
}


@RestApi()
abstract class ApiService {
  factory ApiService(Dio dio, {String baseUrl}) = _ApiService;

  @GET("items/suggestions")
  Future<List<ItemSearchSuggestion>> getSearchSuggestions({
    @Query('input') required String input,
    @CancelRequest() required CancelToken cancelToken,
  });

  @POST("login")
  Future<UserResponse> login(
    @Body() LoginRequest request,
  );

  @POST("logout")
  @Extra({"requiresAuth": true})
  Future<HttpResponse<void>> logout();

  @GET("user")
  @Extra({"requiresAuth": true})
  Future<HttpResponse> getUser();

  @POST("register")
  Future<RegisterResponse> register(
    @Body() RegisterRequest request,
  );
}

@RestApi(baseUrl: "inquiries/")
abstract class InquiryApiService {
  factory InquiryApiService(Dio dio, {String baseUrl}) = _InquiryApiService;

  @GET("")
  Future<ApiResponse<List<NearbyInquiry>>> getNearbyInquiries(
    @Query('latitude') double latitude,
    @Query('longitude') double longitude,
  );

  @GET("{inquiry}")
  Future<Inquiry> getInquiryById(@Path("inquiry") int inquiry);

  @POST("")
  @Extra({"requiresAuth": true})
  @MultiPart()
  Future<HttpResponse> createInquiry({
    @Body() required FormData data,
  });

  @PUT("{inquiry}")
  @Extra({"requiresAuth": true})
  @MultiPart()
  Future<HttpResponse> updateInquiry({
    @Path("inquiry") required int inquiry,
    @Body() required FormData data,
  });

  @DELETE("{inquiry}")
  @Extra({"requiresAuth": true})
  Future<void> deleteInquiry(@Path("inquiry") int inquiry);

  @GET("me")
  @Extra({"requiresAuth": true})
  Future<ApiResponse<List<Inquiry>>> getMyInquiries();
}

@RestApi(baseUrl: "answers/")
abstract class AnswerApiService {
  factory AnswerApiService(Dio dio, {String baseUrl}) = _AnswerApiService;

  @GET("{answer}")
  Future<List<Answer>> getNearbyAnswers({
    @Path('answer') required int answer,
    @Query('query') required String query,
    @Query('latitude') required double latitude,
    @Query('longitude') required double longitude,
    @Query('radius_meters') required double radiusMeters,
  });

  @POST("")
  @Extra({"requiresAuth": true})
  @MultiPart()
  Future<Answer> createAnswer({
    @Body() required FormData data,
  });

  @PUT("{answer}")
  @Extra({"requiresAuth": true})
  @MultiPart()
  Future<Answer> updateAnswer({
    @Path("answer") required int answer,
    @Body() required FormData data,
  });

  @DELETE("{answer}")
  @Extra({"requiresAuth": true})
  Future<void> deleteAnswer(@Path("answer") int answer);

  @GET("me")
  @Extra({"requiresAuth": true})
  Future<List<Answer>> getMyAnswers();
}

abstract class UserApiService {

}
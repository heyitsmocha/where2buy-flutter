import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:w2b_flutter/core/network_results.dart';
import 'package:w2b_flutter/models/answer_model.dart';
import 'package:w2b_flutter/models/inquiry_model.dart';
import 'package:w2b_flutter/models/item_model.dart';
import 'package:w2b_flutter/models/response_model.dart';
import 'package:w2b_flutter/models/user_model.dart';

part 'api_util.g.dart';

class ApiUtil {
  /// A helper method to safely call API methods and handle errors in a consistent way 
  /// 
  /// [onTry] is the API call to execute, which should return an ApiResponse\<T\> 
  /// 
  /// [onDioError] and [onError] can be used to differentiate between DioExceptions (network errors, server errors, etc.) and other types of exceptions (parsing errors, etc.)<br>
  /// 
  /// Otherwise, after awaiting this method, you can check if the result is a Success or Failure and handle it accordingly. 
  /// 
  /// [onFinally] is an optional callback that will be called regardless of whether the API call succeeds or fails.
  static Future<Result<T>> safeApiCall<T>({
    required Future<ApiResponse<T>> Function() onTry,
    Function(T data)? onSuccess,
    Function(DioException e)? onDioError,
    Function(Exception exception)? onError,
    Function()? onFinally
  }) async {
    try {
      final response = await onTry();
      if (response.data != null) {
        onSuccess?.call(response.data as T);
      }
      
      return Result.success(response.data ?? [] as T);
    } on DioException catch (e) {
      onDioError?.call(e);
      return Result.error(e.message ?? e.toString());
    } on Exception catch (e) {
      onError?.call(e);
      return Result.error(e.toString());
    } finally {
      onFinally?.call();
    }
  }
}

@RestApi()
abstract class ApiService {
  factory ApiService(Dio dio, {String baseUrl}) = _ApiService;

  @GET("items/suggestions")
  Future<ApiResponse<List<ItemSearchSuggestion>>> getSearchSuggestions({
    @Query('input') required String input,
    @CancelRequest() required CancelToken cancelToken,
  });

  @GET("items/{item}/nearby-answers")
  Future<ApiResponse<List<Answer>>> getNearbyAnswers({
    @Path('item') required int item,
    @Query('latitude') required double latitude,
    @Query('longitude') required double longitude,
    @Query('range') required double range,
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

  // @GET("{inquiry}")
  // Future<ApiResponse<Inquiry>> getInquiryById(@Path("inquiry") int inquiry);

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

  @GET("{inquiry}/answers")
  Future<ApiResponse<List<Answer>>> getAnswersForInquiry(@Path("inquiry") int inquiry);
}

@RestApi(baseUrl: "answers/")
abstract class AnswerApiService {
  factory AnswerApiService(Dio dio, {String baseUrl}) = _AnswerApiService;

  @POST("")
  @Extra({"requiresAuth": true})
  @MultiPart()
  Future<ApiResponse<Answer>> createAnswer({
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
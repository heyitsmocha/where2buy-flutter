import 'package:dio/dio.dart';
import 'package:w2b_flutter/base_controller.dart';
import 'package:w2b_flutter/core/network_results.dart';

import 'package:w2b_flutter/models/inquiry_model.dart';
import 'package:w2b_flutter/util/api_util.dart';

enum MyInquiriesPageUiEvent implements UIEvent {
  showNetworkErrorSnackbar,
  showUnexpectedErrorSnackbar,
}

class MyInquiriesPageController extends BaseController<MyInquiriesPageUiEvent> {
  final List<Inquiry> _inquiries = [];
  List<Inquiry> get inquiries => _inquiries;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  final Dio _dio;

  MyInquiriesPageController(this._dio);

  Future<void> refresh() async {
    if(isDisposed) return;

    _isLoading = true;
    notifyListeners();

    final result = await ApiUtil.safeApiCall(
      onTry: () async => await InquiryApiService(_dio).getMyInquiries(), 
      onDioError: (error) {
        emitEvent(MyInquiriesPageUiEvent.showNetworkErrorSnackbar);
      }, 
      onError: (error) {
        emitEvent(MyInquiriesPageUiEvent.showUnexpectedErrorSnackbar);
      }
    );

    switch(result) {
      case Success(value: final data):
        _inquiries.clear();
        _inquiries.addAll(data);
        break;
      case Failure():
        // Errors are already handled in the onDioError and onError callbacks, so we don't need to do anything here
        break;
    }
    
    _isLoading = false;
    notifyListeners();
  }
}
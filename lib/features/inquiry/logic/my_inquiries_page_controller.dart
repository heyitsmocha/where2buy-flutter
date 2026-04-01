import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';
import 'package:w2b_flutter/base_controller.dart';

import 'package:w2b_flutter/models/inquiry_model.dart';
import 'package:w2b_flutter/util/api_util.dart';
import 'package:w2b_flutter/util/location_util.dart';

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

    try {
      Position position = await LocationUtil.getCurrentLocation();
      List<Inquiry> value = await InquiryApiService(_dio).getInquiries(
        position.latitude, 
        position.longitude
      );
      _inquiries.clear();
      _inquiries.addAll(value);
    } on DioException catch (e) {
      emitEvent(MyInquiriesPageUiEvent.showNetworkErrorSnackbar);
    } catch (e) {
      emitEvent(MyInquiriesPageUiEvent.showUnexpectedErrorSnackbar);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
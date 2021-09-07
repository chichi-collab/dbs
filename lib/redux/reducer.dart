import 'actions/useractions.dart';
import 'appstate.dart';

AppState appStateReducer(AppState state, action) {
  return AppState(
      user: action is GetUserActionSuccess ? action.user : state.user,
      userLocation: action is GetUserLocationSuccess
          ? action.userLocation
          : state.userLocation,
      products:
          action is GetProductActionSuccess ? action.products : state.products);
  // return state;
}

const String baseUrl = "http://192.168.6.102:2222/api/v1";
const String appName = "NAMA APP";

Map<String, String> globalHeaders = {
  'Content-Type': 'application/x-www-form-urlencoded',
  'Accept': 'application/json',
};

//Auth
const String urlAuthLogin = "/auth/login";
const String urlAuthRegister = "/auth/register";
const String urlAuthCheckToken = "/auth/check_token";
const String urlAuthRefreshToken = "/auth/refresh-token";
const String urlAuthLogout = "/auth/logout";

//Pencari Layanan
const String urlPencariLayanan = "/pencari_layanan";
const String urlPencariLayananDetail = "/pencari_layanan/detail";
const String urlPencariLayananQuisioner = "/pencari_layanan/quisioner";
const String urlPencariLayananGmaps = "/pencari_layanan/gmaps";

//Penyedia Layanan
const String urlPenyediaLayanan = "/penyedia_layanan";
const String urlPenyediaLayananProfile = "/penyedia_layanan/profile";
const String urlPenyediaLayananRequest = "/penyedia_layanan/request";
const String urlPenyediaLayananDetailRequest =
    "/penyedia_layanan/request/detail";

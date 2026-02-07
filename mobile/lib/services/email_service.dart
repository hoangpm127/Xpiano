import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class EmailService {
  // --- THÔNG TIN TÀI KHOẢN EMAIL CỦA BẠN (CUSTOM SMTP) ---
  // Thay thế bằng email và mật khẩu ứng dụng của bạn
  // Ví dụ: Gmail (yêu cầu App Password): https://myaccount.google.com/apppasswords
  
  static const String _username = 'hoangpm127@gmail.com'; // Email hiển thị
  static const String _password = 'bwrr pops vziv sfqq'; // Mật khẩu ứng dụng (KHÔNG phải mk đăng nhập Google)
  
  // Gửi OTP qua SMTP Gmail
  static Future<void> sendOtp(String recipientEmail, String otp) async {
    // Cấu hình SMTP Server (Gmail)
    // Nếu dùng host khác (như SendGrid, Mailgun...), dùng SmtpServer('smtp.example.com', ...)
    final smtpServer = gmail(_username, _password);
    
    // Tạo nội dung Email chuyên nghiệp
    final message = Message()
      ..from = Address(_username, 'Spiano Team')
      ..recipients.add(recipientEmail)
      ..subject = 'Mã xác thực đăng ký Spiano: $otp'
      ..html = '''
        <div style="font-family: Arial, sans-serif; padding: 20px; background-color: #f4f4f4;">
          <div style="max-width: 600px; margin: 0 auto; background-color: #ffffff; border-radius: 8px; overflow: hidden; box-shadow: 0 4px 6px rgba(0,0,0,0.1);">
            <div style="background-color: #121212; padding: 20px; text-align: center;">
              <h1 style="color: #D4AF37; margin: 0;">Spiano</h1>
            </div>
            <div style="padding: 30px; text-align: center;">
              <h2 style="color: #333333;">Xác thực Tài khoản</h2>
              <p style="color: #666666; font-size: 16px;">Chào mừng bạn đến với Spiano! Mã xác thực của bạn là:</p>
              <div style="background-color: #f8f9fa; border: 1px solid #e9ecef; border-radius: 4px; padding: 15px; margin: 20px 0; font-size: 24px; font-weight: bold; letter-spacing: 5px; color: #D4AF37;">
                $otp
              </div>
              <p style="color: #999999; font-size: 14px;">Mã này có hiệu lực trong 5 phút. Vui lòng không chia sẻ cho bất kỳ ai.</p>
            </div>
            <div style="background-color: #f8f9fa; padding: 15px; text-align: center; color: #999999; font-size: 12px;">
              &copy; 2024 Spiano App. All rights reserved.
            </div>
          </div>
        </div>
      ''';

    try {
      final sendReport = await send(message, smtpServer);
      print('Email sent: ' + sendReport.toString());
    } catch (e) {
      print('Email not sent. \n' + e.toString());
      // Re-throw để UI biết đường xử lý
      throw Exception('Lỗi gửi email: $e'); 
    }
  }
}

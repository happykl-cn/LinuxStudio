<?php
/**
 * ===============================================
 * Linux Studio 联系表单邮件系统
 * ===============================================
 * 
 * 功能：
 * - 接收联系表单提交
 * - 发送邮件到管理员
 * - 自动回复用户
 * - 防刷保护
 * 
 * 使用方法：
 * POST JSON 数据到此文件
 */

// ===============================================
// 安全和错误处理
// ===============================================
error_reporting(E_ALL);
ini_set('display_errors', 0);
ini_set('log_errors', 1);

// 安全头
header("X-Frame-Options: DENY");
header("X-XSS-Protection: 1; mode=block");
header("X-Content-Type-Options: nosniff");
header("Referrer-Policy: strict-origin-when-cross-origin");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");

// 处理 OPTIONS 请求
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

// ===============================================
// SMTP 配置
// ===============================================
define('SMTP_HOST', 'smtp.qiye.aliyun.com');
define('SMTP_PORT', 465);
define('SMTP_USER', 'iloveshit@happykl.cn');
define('SMTP_PASS', 'Abczcx051018');
define('SMTP_FROM', 'iloveshit@happykl.cn');
define('SMTP_FROM_NAME', 'Linux Studio');
define('CONTACT_EMAIL', '3269802935@qq.com');
define('RATE_LIMIT', 300); // 防刷间隔(秒)

// ===============================================
// 加载 PHPMailer
// ===============================================
use PHPMailer\PHPMailer\PHPMailer;
use PHPMailer\PHPMailer\Exception;

// 尝试多个可能的路径
if (!class_exists('PHPMailer\PHPMailer\PHPMailer')) {
    $paths = [
        __DIR__ . '/vendor/autoload.php',
        __DIR__ . '/../vendor/autoload.php',
        __DIR__ . '/vendor/phpmailer/phpmailer/src/PHPMailer.php',
    ];
    
    foreach ($paths as $path) {
        if (file_exists($path)) {
            if (strpos($path, 'autoload.php') !== false) {
                require_once $path;
            } else {
                $dir = dirname($path);
                require_once $dir . '/Exception.php';
                require_once $dir . '/PHPMailer.php';
                require_once $dir . '/SMTP.php';
            }
            break;
        }
    }
}

// ===============================================
// 核心邮件发送函数
// ===============================================
function sendEmail($to, $subject, $body, $isHTML = false) {
    $mail = new PHPMailer(true);
    
    try {
        // SMTP 配置
        $mail->isSMTP();
        $mail->Host = SMTP_HOST;
        $mail->SMTPAuth = true;
        $mail->Username = SMTP_USER;
        $mail->Password = SMTP_PASS;
        
        // 根据端口自动选择加密方式
        if (SMTP_PORT == 465) {
            $mail->SMTPSecure = PHPMailer::ENCRYPTION_SMTPS;  // SSL
        } elseif (SMTP_PORT == 587) {
            $mail->SMTPSecure = PHPMailer::ENCRYPTION_STARTTLS;  // TLS
        } else {
            $mail->SMTPSecure = false;  // 不加密
            $mail->SMTPAutoTLS = false;  // 禁用自动TLS
        }
        
        $mail->Port = SMTP_PORT;
        $mail->CharSet = 'UTF-8';
        
        // 调试和超时设置
        $mail->SMTPDebug = 0;  // 生产环境设为0，调试时设为2
        $mail->Timeout = 30;
        $mail->SMTPKeepAlive = true;
        
        // 发件人和收件人
        $mail->setFrom(SMTP_FROM, SMTP_FROM_NAME);
        $mail->addAddress($to);
        $mail->addReplyTo(SMTP_FROM, SMTP_FROM_NAME);
        
        // 邮件内容
        $mail->isHTML($isHTML);
        $mail->Subject = $subject;
        $mail->Body = $body;
        
        $mail->send();
        return ['success' => true, 'message' => '邮件发送成功'];
    } catch (Exception $e) {
        error_log("邮件发送失败 [$to]: " . $mail->ErrorInfo);
        return ['success' => false, 'message' => '邮件发送失败: ' . $mail->ErrorInfo];
    }
}

// ===============================================
// 防刷检查
// ===============================================
function checkRateLimit($identifier) {
    $ip = $_SERVER['REMOTE_ADDR'];
    $lockFile = sys_get_temp_dir() . '/email_' . md5($ip . $identifier) . '.lock';
    
    if (file_exists($lockFile)) {
        $lastTime = (int)file_get_contents($lockFile);
        $remaining = RATE_LIMIT - (time() - $lastTime);
        if ($remaining > 0) {
            return [
                'success' => false, 
                'message' => "提交过于频繁，请等待 {$remaining} 秒后再试"
            ];
        }
    }
    
    file_put_contents($lockFile, time());
    return ['success' => true];
}

// ===============================================
// HTML 邮件模板
// ===============================================
function getEmailTemplate($title, $content, $footer = '') {
    return '
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>' . $title . '</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { 
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            padding: 40px 20px;
        }
        .email-container {
            max-width: 600px;
            margin: 0 auto;
            background: #ffffff;
            border-radius: 16px;
            overflow: hidden;
            box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
        }
        .email-header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            padding: 40px 30px;
            text-align: center;
        }
        .logo-container {
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 12px;
            margin-bottom: 16px;
        }
        .logo-icon {
            width: 48px;
            height: 48px;
            background: rgba(255, 255, 255, 0.2);
            border-radius: 12px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 24px;
        }
        .logo-text {
            font-size: 28px;
            font-weight: 800;
            color: #ffffff;
            letter-spacing: -0.5px;
        }
        .email-title {
            font-size: 24px;
            font-weight: 600;
            color: #ffffff;
            margin-top: 8px;
        }
        .email-body {
            padding: 40px 30px;
            color: #1f2937 !important;
            line-height: 1.8;
        }
        .email-body p {
            color: #1f2937 !important;
        }
        .content-section {
            margin-bottom: 24px;
        }
        .section-title {
            font-size: 18px;
            font-weight: 600;
            color: #667eea;
            margin-bottom: 12px;
            padding-bottom: 8px;
            border-bottom: 2px solid #e5e7eb;
        }
        .info-row {
            display: flex;
            padding: 12px 0;
            border-bottom: 1px solid #f3f4f6;
        }
        .info-label {
            font-weight: 600;
            color: #6b7280;
            min-width: 100px;
        }
        .info-value {
            color: #1f2937 !important;
            flex: 1;
        }
        .info-value a {
            color: #667eea !important;
        }
        .message-box {
            background: #f9fafb;
            border-left: 4px solid #667eea;
            padding: 20px;
            border-radius: 8px;
            margin: 20px 0;
        }
        .message-box p {
            color: #374151 !important;
            line-height: 1.8;
            white-space: pre-wrap;
        }
        .button {
            display: inline-block;
            padding: 14px 32px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: #ffffff !important;
            text-decoration: none;
            border-radius: 8px;
            font-weight: 600;
            margin: 20px 0;
            box-shadow: 0 4px 14px rgba(102, 126, 234, 0.4);
        }
        .email-footer {
            background: #f9fafb;
            padding: 30px;
            text-align: center;
            border-top: 1px solid #e5e7eb;
        }
        .footer-text {
            color: #6b7280 !important;
            font-size: 14px;
            margin-bottom: 8px;
        }
        .footer-links {
            margin-top: 16px;
        }
        .footer-links a {
            color: #667eea !important;
            text-decoration: none;
            margin: 0 12px;
            font-size: 14px;
        }
        .divider {
            height: 1px;
            background: linear-gradient(90deg, transparent, #e5e7eb, transparent);
            margin: 30px 0;
        }
        @media only screen and (max-width: 600px) {
            .email-body { padding: 30px 20px; }
            .email-header { padding: 30px 20px; }
            .logo-text { font-size: 24px; }
            .email-title { font-size: 20px; }
        }
    </style>
</head>
<body>
    <div class="email-container">
        <div class="email-header">
            <div class="logo-container">
                <div class="logo-icon">🐧</div>
                <div class="logo-text">Linux Studio</div>
            </div>
            <div class="email-title">' . $title . '</div>
        </div>
        <div class="email-body">
            ' . $content . '
        </div>
        <div class="email-footer">
            <p class="footer-text" style="margin-bottom: 4px;">此邮件由 Linux Studio 系统自动发送</p>
            <p class="footer-text" style="font-size: 12px; color: #9ca3af !important; margin-bottom: 8px;">This email was sent automatically by Linux Studio</p>
            <p class="footer-text">' . date('Y-m-d H:i:s') . '</p>
            ' . $footer . '
            <div class="footer-links">
                <a href="https://yourwebsite.com">官方网站 Website</a>
                <a href="https://github.com/yourusername">GitHub</a>
                <a href="mailto:' . SMTP_FROM . '">联系我们 Contact</a>
            </div>
        </div>
    </div>
</body>
</html>';
}

// ===============================================
// 数据验证
// ===============================================
function validateInput($data, $type = 'contact') {
    $errors = [];
    
    // 验证姓名
    if (empty($data['name']) || strlen(trim($data['name'])) < 2) {
        $errors[] = '姓名至少需要2个字符';
    }
    
    // 验证邮箱
    if (empty($data['email']) || !filter_var($data['email'], FILTER_VALIDATE_EMAIL)) {
        $errors[] = '请提供有效的邮箱地址';
    }
    
    // 验证消息内容
    if ($type === 'moderator') {
        // 版主申请验证
        if (empty($data['message']) || strlen(trim($data['message'])) < 20) {
            $errors[] = '申请理由至少需要20个字符';
        }
    } else {
        // 联系表单验证
        if (empty($data['message']) || strlen(trim($data['message'])) < 10) {
            $errors[] = '消息内容至少需要10个字符';
        }
    }
    
    return $errors;
}

// ===============================================
// API 处理
// ===============================================
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    header('Content-Type: application/json; charset=utf-8');
    
    // 读取 POST 数据
    $input = file_get_contents('php://input');
    $data = json_decode($input, true);
    
    if (!$data) {
        http_response_code(400);
        echo json_encode([
            'success' => false, 
            'message' => '无效的请求数据'
        ]);
        exit;
    }
    
    // 获取类型
    $type = $data['type'] ?? 'contact';
    
    // 验证输入
    $errors = validateInput($data, $type);
    if (!empty($errors)) {
        http_response_code(400);
        echo json_encode([
            'success' => false, 
            'message' => implode('; ', $errors)
        ]);
        exit;
    }
    
    // 防刷检查
    $rateCheck = checkRateLimit($data['email']);
    if (!$rateCheck['success']) {
        http_response_code(429);
        echo json_encode($rateCheck);
        exit;
    }
    
    // 安全过滤
    $name = htmlspecialchars(trim($data['name']), ENT_QUOTES, 'UTF-8');
    $email = filter_var(trim($data['email']), FILTER_SANITIZE_EMAIL);
    $subject = isset($data['subject']) ? htmlspecialchars(trim($data['subject']), ENT_QUOTES, 'UTF-8') : '网站咨询';
    $message = htmlspecialchars(trim($data['message']), ENT_QUOTES, 'UTF-8');
    $type = $data['type'] ?? 'contact';
    
    // 根据类型构建邮件内容
    if ($type === 'moderator') {
        // 版主申请邮件 - 发送给管理员
        $emailSubject = "新的版主申请 - {$name}";
        
        $adminContent = '
            <div class="content-section">
                <h2 class="section-title">📋 申请人信息 Applicant Information</h2>
                <div class="info-row">
                    <span class="info-label">姓名 Name</span>
                    <span class="info-value">' . $name . '</span>
                </div>
                <div class="info-row">
                    <span class="info-label">邮箱 Email</span>
                    <span class="info-value">' . $email . '</span>
                </div>
                <div class="info-row">
                    <span class="info-label">申请板块 Category</span>
                    <span class="info-value">' . ($data['category'] ?? '未提供') . '</span>
                </div>
                <div class="info-row">
                    <span class="info-label">相关经验 Experience</span>
                    <span class="info-value">' . ($data['experience'] ?? '未提供') . '</span>
                </div>
                <div class="info-row">
                    <span class="info-label">可投入时间 Time</span>
                    <span class="info-value">' . ($data['time'] ?? '未提供') . '</span>
                </div>
                <div class="info-row">
                    <span class="info-label">GitHub</span>
                    <span class="info-value">' . ($data['github'] ?? '未提供') . '</span>
                </div>
            </div>
            
            <div class="content-section">
                <h2 class="section-title">💬 申请理由 Application Reason</h2>
                <div class="message-box">
                    <p>' . nl2br($message) . '</p>
                </div>
            </div>
            
            <div class="divider"></div>
            
            <div class="content-section">
                <div class="info-row">
                    <span class="info-label">IP地址 IP</span>
                    <span class="info-value">' . $_SERVER['REMOTE_ADDR'] . '</span>
                </div>
            </div>
        ';
        
        $emailBody = getEmailTemplate('新的版主申请', $adminContent);
        
        // 自动回复给用户
        $autoReplySubject = "Linux Studio - 版主申请已收到 | Moderator Application Received";
        
        $userContent = '
            <p style="font-size: 16px; margin-bottom: 8px; color: #1f2937 !important;">尊敬的 <strong>' . $name . '</strong>，</p>
            <p style="font-size: 14px; margin-bottom: 24px; color: #6b7280 !important;">Dear <strong>' . $name . '</strong>,</p>
            
            <p style="margin-bottom: 8px; color: #1f2937 !important;">感谢您申请成为 <strong>Linux Studio</strong> 社区版主！</p>
            <p style="margin-bottom: 20px; color: #6b7280 !important; font-size: 14px;">Thank you for applying to become a moderator for <strong>Linux Studio</strong> community!</p>
            
            <div class="message-box" style="margin: 24px 0; background: #f0f9ff; border-left: 4px solid #667eea; padding: 20px; border-radius: 8px;">
                <p style="margin-bottom: 8px; color: #1f2937 !important;">✅ 我们已经成功收到您的申请</p>
                <p style="margin-bottom: 16px; color: #6b7280 !important; font-size: 14px; padding-left: 24px;">We have successfully received your application</p>
                
                <p style="margin-bottom: 8px; color: #1f2937 !important;">⏰ 团队将在 1-3 个工作日内进行审核</p>
                <p style="margin-bottom: 16px; color: #6b7280 !important; font-size: 14px; padding-left: 24px;">Our team will review within 1-3 business days</p>
                
                <p style="margin-bottom: 8px; color: #1f2937 !important;">📧 审核结果将通过邮件通知您</p>
                <p style="color: #6b7280 !important; font-size: 14px; padding-left: 24px;">Review results will be sent via email</p>
            </div>
            
            <p style="margin-bottom: 8px; color: #1f2937 !important; font-weight: 600;">您的申请详情</p>
            <p style="margin-bottom: 12px; color: #6b7280 !important; font-size: 14px;">Your Application Details</p>
            <div style="background: #f9fafb; padding: 20px; border-radius: 8px; margin: 16px 0;">
                <p style="color: #374151 !important; margin-bottom: 8px;"><strong>申请板块 Category:</strong> ' . ($data['category'] ?? '未提供') . '</p>
                <p style="color: #374151 !important; margin-bottom: 8px;"><strong>相关经验 Experience:</strong> ' . ($data['experience'] ?? '未提供') . '</p>
                <p style="color: #374151 !important;"><strong>可投入时间 Time Commitment:</strong> ' . ($data['time'] ?? '未提供') . '</p>
            </div>
            
            <div class="divider"></div>
            
            <p style="margin-top: 24px; margin-bottom: 8px; color: #6b7280 !important;">再次感谢您对 Linux Studio 社区的支持！</p>
            <p style="margin-bottom: 20px; color: #9ca3af !important; font-size: 14px;">Thank you again for your support of the Linux Studio community!</p>
            
            <p style="color: #1f2937 !important; font-weight: 600;">祝好 Best regards,</p>
            <p style="color: #1f2937 !important; font-weight: 600;">Linux Studio 团队 Team</p>
        ';
        
        $autoReplyBody = getEmailTemplate('版主申请已收到', $userContent);
    } else {
        // 普通联系表单 - 发送给管理员
        $emailSubject = "网站联系表单 - {$subject}";
        
        $adminContent = '
            <div class="content-section">
                <h2 class="section-title">👤 发件人信息 Sender Information</h2>
                <div class="info-row">
                    <span class="info-label">姓名 Name</span>
                    <span class="info-value">' . $name . '</span>
                </div>
                <div class="info-row">
                    <span class="info-label">邮箱 Email</span>
                    <span class="info-value"><a href="mailto:' . $email . '" style="color: #667eea;">' . $email . '</a></span>
                </div>
                <div class="info-row">
                    <span class="info-label">主题 Subject</span>
                    <span class="info-value">' . $subject . '</span>
                </div>
            </div>
            
            <div class="content-section">
                <h2 class="section-title">💬 消息内容 Message</h2>
                <div class="message-box">
                    <p>' . nl2br($message) . '</p>
                </div>
            </div>
            
            <div style="text-align: center; margin: 30px 0;">
                <a href="mailto:' . $email . '" class="button">立即回复 Reply Now</a>
            </div>
            
            <div class="divider"></div>
            
            <div class="content-section">
                <div class="info-row">
                    <span class="info-label">IP地址 IP</span>
                    <span class="info-value">' . $_SERVER['REMOTE_ADDR'] . '</span>
                </div>
            </div>
        ';
        
        $emailBody = getEmailTemplate('新的联系表单', $adminContent);
        
        // 自动回复给用户
        $autoReplySubject = "Linux Studio - 我们已收到您的消息 | Message Received";
        
        $userContent = '
            <p style="font-size: 16px; margin-bottom: 8px; color: #1f2937 !important;">尊敬的 <strong>' . $name . '</strong>，</p>
            <p style="font-size: 14px; margin-bottom: 24px; color: #6b7280 !important;">Dear <strong>' . $name . '</strong>,</p>
            
            <p style="margin-bottom: 8px; color: #1f2937 !important;">感谢您联系 <strong>Linux Studio</strong>！</p>
            <p style="margin-bottom: 20px; color: #6b7280 !important; font-size: 14px;">Thank you for contacting <strong>Linux Studio</strong>!</p>
            
            <div class="message-box" style="margin: 24px 0; background: #f0f9ff; border-left: 4px solid #667eea; padding: 20px; border-radius: 8px;">
                <p style="margin-bottom: 8px; color: #1f2937 !important;">✅ 我们已经成功收到您的消息</p>
                <p style="margin-bottom: 16px; color: #6b7280 !important; font-size: 14px; padding-left: 24px;">We have successfully received your message</p>
                
                <p style="margin-bottom: 8px; color: #1f2937 !important;">⏰ 团队将尽快回复您</p>
                <p style="margin-bottom: 16px; color: #6b7280 !important; font-size: 14px; padding-left: 24px;">Our team will reply to you as soon as possible</p>
                
                <p style="margin-bottom: 8px; color: #1f2937 !important;">📧 通常我们会在 24-48 小时内给您答复</p>
                <p style="color: #6b7280 !important; font-size: 14px; padding-left: 24px;">We typically respond within 24-48 hours</p>
            </div>
            
            <p style="margin-bottom: 8px; font-weight: 600; color: #1f2937 !important;">您的消息</p>
            <p style="margin-bottom: 12px; color: #6b7280 !important; font-size: 14px;">Your Message</p>
            <div style="background: #f9fafb; padding: 20px; border-radius: 8px; margin: 16px 0; border-left: 3px solid #e5e7eb;">
                <p style="color: #374151 !important; line-height: 1.8;">' . nl2br($message) . '</p>
            </div>
            
            <div class="divider"></div>
            
            <p style="margin-top: 24px; margin-bottom: 8px; color: #6b7280 !important;">如有紧急问题，您也可以直接回复此邮件。</p>
            <p style="margin-bottom: 20px; color: #9ca3af !important; font-size: 14px;">For urgent matters, you can reply to this email directly.</p>
            
            <p style="color: #1f2937 !important; font-weight: 600;">祝好 Best regards,</p>
            <p style="color: #1f2937 !important; font-weight: 600;">Linux Studio 团队 Team</p>
        ';
        
        $autoReplyBody = getEmailTemplate('消息已收到', $userContent);
    }
    
    // 发送邮件到管理员（使用 HTML）
    $result = sendEmail(CONTACT_EMAIL, $emailSubject, $emailBody, true);
    
    // 如果发送成功，发送自动回复给用户（使用 HTML）
    if ($result['success']) {
        sendEmail($email, $autoReplySubject, $autoReplyBody, true);
        
        echo json_encode([
            'success' => true,
            'message' => '感谢您的留言！我们已收到您的消息，将尽快回复您。'
        ]);
    } else {
        http_response_code(500);
        echo json_encode($result);
    }
    
    exit;
}

// ===============================================
// 默认响应 - 仅API模式
// ===============================================
http_response_code(405);
header('Content-Type: application/json; charset=utf-8');
echo json_encode([
    'success' => false,
    'message' => '此 API 仅接受 POST 请求。请从前端表单提交数据。'
]);
exit;

<?php
/**
 * Star 计数系统 API
 * 使用 txt 文件存储 star 数据
 */

header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST');
header('Access-Control-Allow-Headers: Content-Type');

// 数据文件路径
$dataFile = __DIR__ . '/star_data.txt';
$usersFile = __DIR__ . '/star_users.txt';

// 确保数据文件存在
if (!file_exists($dataFile)) {
    file_put_contents($dataFile, '0');
}

if (!file_exists($usersFile)) {
    file_put_contents($usersFile, '');
}

/**
 * 获取总 Star 数
 */
function getTotalStars($file) {
    $content = file_get_contents($file);
    return (int)trim($content);
}

/**
 * 保存总 Star 数
 */
function saveTotalStars($file, $count) {
    file_put_contents($file, $count);
}

/**
 * 检查用户是否已经 Star
 */
function hasUserStarred($file, $userId) {
    $content = file_get_contents($file);
    $users = array_filter(explode("\n", $content));
    return in_array($userId, $users);
}

/**
 * 添加用户 Star
 */
function addUserStar($file, $userId) {
    if (!hasUserStarred($file, $userId)) {
        file_put_contents($file, $userId . "\n", FILE_APPEND);
        return true;
    }
    return false;
}

/**
 * 移除用户 Star
 */
function removeUserStar($file, $userId) {
    $content = file_get_contents($file);
    $users = array_filter(explode("\n", $content));
    $users = array_diff($users, [$userId]);
    file_put_contents($file, implode("\n", $users) . "\n");
}

/**
 * 生成用户 ID（基于 IP 和 User Agent）
 */
function generateUserId() {
    $ip = $_SERVER['REMOTE_ADDR'] ?? 'unknown';
    $userAgent = $_SERVER['HTTP_USER_AGENT'] ?? 'unknown';
    return md5($ip . $userAgent);
}

// 处理请求
$method = $_SERVER['REQUEST_METHOD'];

try {
    if ($method === 'GET') {
        // 获取 Star 数据
        $userId = generateUserId();
        $totalStars = getTotalStars($dataFile);
        $userStarred = hasUserStarred($usersFile, $userId);
        
        echo json_encode([
            'success' => true,
            'totalStars' => $totalStars,
            'userStarred' => $userStarred,
            'userId' => $userId
        ]);
        
    } elseif ($method === 'POST') {
        // 切换 Star 状态
        $input = json_decode(file_get_contents('php://input'), true);
        $userId = $input['userId'] ?? generateUserId();
        
        $totalStars = getTotalStars($dataFile);
        $userStarred = hasUserStarred($usersFile, $userId);
        
        if ($userStarred) {
            // 取消 Star
            removeUserStar($usersFile, $userId);
            $totalStars = max(0, $totalStars - 1);
            saveTotalStars($dataFile, $totalStars);
            
            echo json_encode([
                'success' => true,
                'action' => 'unstar',
                'totalStars' => $totalStars,
                'userStarred' => false,
                'message' => '已取消 Star'
            ]);
        } else {
            // 添加 Star
            addUserStar($usersFile, $userId);
            $totalStars = $totalStars + 1;
            saveTotalStars($dataFile, $totalStars);
            
            echo json_encode([
                'success' => true,
                'action' => 'star',
                'totalStars' => $totalStars,
                'userStarred' => true,
                'message' => '感谢您的 Star！⭐'
            ]);
        }
    } else {
        throw new Exception('不支持的请求方法');
    }
    
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => $e->getMessage()
    ]);
}


// ===========================
// Performance Optimization
// ===========================
// Detect if user prefers reduced motion
const prefersReducedMotion = window.matchMedia('(prefers-reduced-motion: reduce)').matches;

// Add class to body for reduced motion
if (prefersReducedMotion) {
    document.body.classList.add('reduce-motion');
}

// 检测设备性能
function detectPerformance() {
    const isLowEnd = 
        // 低内存设备
        (navigator.deviceMemory && navigator.deviceMemory < 4) ||
        // 低核心数
        (navigator.hardwareConcurrency && navigator.hardwareConcurrency < 4) ||
        // 移动设备
        /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent);
    
    if (isLowEnd) {
        document.body.classList.add('low-performance');
        console.log('[性能优化] 检测到低性能设备，已启用性能优化模式');
    }
    
    return !isLowEnd;
}

const isHighPerformance = detectPerformance();

// Throttle function for performance
function throttle(func, wait) {
    let timeout;
    return function executedFunction(...args) {
        const later = () => {
            clearTimeout(timeout);
            func(...args);
        };
        clearTimeout(timeout);
        timeout = setTimeout(later, wait);
    };
}

// ===========================
// Navigation Scroll Effect
// ===========================
const navbar = document.getElementById('navbar');
let lastScroll = 0;

let scrollTimeout;
let isScrolling = false;

const handleScroll = throttle(() => {
    const currentScroll = window.pageYOffset;
    
    if (currentScroll > 50) {
        navbar.classList.add('scrolled');
    } else {
        navbar.classList.remove('scrolled');
    }
    
    // 滚动时暂停动画以提升性能
    if (!isScrolling) {
        isScrolling = true;
        document.body.classList.add('is-scrolling');
    }
    
    // 清除之前的超时
    clearTimeout(scrollTimeout);
    
    // 滚动停止后恢复动画
    scrollTimeout = setTimeout(() => {
        isScrolling = false;
        document.body.classList.remove('is-scrolling');
    }, 150);
    
    lastScroll = currentScroll;
}, 100);

window.addEventListener('scroll', handleScroll, { passive: true });

// ===========================
// Copy to Clipboard
// ===========================
function setupCopyButtons() {
    const copyButtons = document.querySelectorAll('.copy-btn');
    
    copyButtons.forEach(button => {
        button.addEventListener('click', async () => {
            const commandBox = button.closest('.command-box');
            const code = commandBox.querySelector('code');
            const text = code.textContent;
            
            try {
                await navigator.clipboard.writeText(text);
                
                // Visual feedback
                button.classList.add('copied');
                const originalHTML = button.innerHTML;
                button.innerHTML = '<svg width="18" height="18" viewBox="0 0 18 18" fill="none"><path d="M3 9L7 13L15 5" stroke="currentColor" stroke-width="2" stroke-linecap="round"/></svg>';
                
                setTimeout(() => {
                    button.classList.remove('copied');
                    button.innerHTML = originalHTML;
                }, 2000);
            } catch (err) {
                console.error('Failed to copy:', err);
            }
        });
    });
}

setupCopyButtons();

// ===========================
// Terminal Animation
// ===========================
const terminalBody = document.getElementById('terminalBody');

const terminalCommands = [
    { type: 'command', text: 'linux-studio install panel' },
    { type: 'output', text: '正在下载 Linux Studio Panel...' },
    { type: 'output', text: '正在安装依赖...' },
    { type: 'success', text: '✓ 安装成功' },
    { type: 'output', text: '面板地址: http://localhost:8080' },
    { type: 'command', text: 'linux-studio install nginx' },
    { type: 'output', text: '正在下载 Nginx 插件...' },
    { type: 'success', text: '✓ Nginx 安装成功' },
    { type: 'success', text: '✓ 服务已启动于 http://localhost:80' }
];

let commandIndex = 0;
let isAnimating = false;

function typeCommand(text, callback) {
    const line = document.createElement('div');
    line.className = 'terminal-line';
    
    const prompt = document.createElement('span');
    prompt.className = 'terminal-prompt';
    prompt.textContent = '$';
    
    const textSpan = document.createElement('span');
    textSpan.className = 'terminal-text';
    
    const cursor = document.createElement('span');
    cursor.className = 'terminal-cursor';
    
    line.appendChild(prompt);
    line.appendChild(textSpan);
    line.appendChild(cursor);
    terminalBody.appendChild(line);
    
    let i = 0;
    const typingInterval = setInterval(() => {
        if (i < text.length) {
            textSpan.textContent += text[i];
            i++;
        } else {
            clearInterval(typingInterval);
            cursor.remove();
            callback();
        }
    }, 50);
}

function addOutput(text, type) {
    const line = document.createElement('div');
    line.className = 'terminal-line';
    
    const output = document.createElement('span');
    output.className = type === 'success' ? 'terminal-output terminal-success' : 'terminal-output';
    output.textContent = text;
    
    line.appendChild(output);
    terminalBody.appendChild(line);
}

function runTerminalAnimation() {
    if (isAnimating || commandIndex >= terminalCommands.length) {
        return;
    }
    
    isAnimating = true;
    const current = terminalCommands[commandIndex];
    
    if (current.type === 'command') {
        typeCommand(current.text, () => {
            commandIndex++;
            isAnimating = false;
            setTimeout(runTerminalAnimation, 500);
        });
    } else {
        addOutput(current.text, current.type);
        commandIndex++;
        isAnimating = false;
        setTimeout(runTerminalAnimation, 300);
    }
}

// Start terminal animation when in viewport
const observer = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
        if (entry.isIntersecting && commandIndex === 0) {
            setTimeout(runTerminalAnimation, 500);
        }
    });
}, { threshold: 0.5 });

observer.observe(terminalBody);

// ===========================
// Plugin Categories
// ===========================
const plugins = {
    web: [
        { icon: '🌐', name: 'Nginx', description: '高性能Web服务器和反向代理' },
        { icon: '🔥', name: 'Apache', description: '功能强大的HTTP服务器' },
        { icon: '📦', name: 'Node.js', description: 'JavaScript运行时环境' },
        { icon: '🐘', name: 'PHP', description: 'PHP运行环境和扩展管理' },
        { icon: '⚡', name: 'Caddy', description: '自动HTTPS的现代Web服务器' }
    ],
    database: [
        { icon: '🐬', name: 'MySQL', description: '流行的关系型数据库' },
        { icon: '🐘', name: 'PostgreSQL', description: '先进的开源关系型数据库' },
        { icon: '🔴', name: 'Redis', description: '内存数据结构存储' },
        { icon: '🍃', name: 'MongoDB', description: 'NoSQL文档数据库' },
        { icon: '⚡', name: 'Elasticsearch', description: '分布式搜索和分析引擎' }
    ],
    security: [
        { icon: '🦈', name: 'Wireshark', description: '网络协议分析工具' },
        { icon: '🗺️', name: 'Nmap', description: '网络发现和安全审计' },
        { icon: '🔐', name: 'OpenSSL', description: 'SSL/TLS加密工具包' },
        { icon: '🛡️', name: 'Fail2ban', description: '入侵防御软件' },
        { icon: '🔍', name: 'ClamAV', description: '开源防病毒引擎' }
    ],
    devtools: [
        { icon: '🐳', name: 'Docker', description: '容器化平台' },
        { icon: '☸️', name: 'Kubernetes', description: '容器编排系统' },
        { icon: '📝', name: 'Git', description: '版本控制系统' },
        { icon: '🔄', name: 'Jenkins', description: 'CI/CD自动化服务器' },
        { icon: '🤖', name: 'ROS2', description: '机器人操作系统' }
    ],
    monitoring: [
        { icon: '📊', name: 'Grafana', description: '可视化和分析平台' },
        { icon: '📈', name: 'Prometheus', description: '监控和告警工具包' },
        { icon: '📋', name: 'ELK Stack', description: '日志分析解决方案' },
        { icon: '🔔', name: 'Zabbix', description: '企业级监控解决方案' },
        { icon: '👁️', name: 'Netdata', description: '实时性能监控' }
    ]
};

const pluginList = document.getElementById('pluginList');
const categoryButtons = document.querySelectorAll('.plugin-category');

function renderPlugins(category) {
    pluginList.innerHTML = '';
    
    plugins[category].forEach((plugin, index) => {
        const pluginItem = document.createElement('div');
        pluginItem.className = 'plugin-item';
        pluginItem.style.opacity = '0';
        pluginItem.style.transform = 'translateY(20px)';
        
        pluginItem.innerHTML = `
            <div class="plugin-icon">${plugin.icon}</div>
            <div class="plugin-info">
                <div class="plugin-name" data-translate="">${plugin.name}</div>
                <div class="plugin-description" data-translate="">${plugin.description}</div>
            </div>
            <button class="plugin-action" data-translate="">安装</button>
        `;
        
        pluginList.appendChild(pluginItem);
        
        // 如果翻译系统已初始化且当前是英文，立即翻译这些新元素
        if (window.i18n && window.i18n.currentLang === 'en') {
            const nameEl = pluginItem.querySelector('.plugin-name');
            const descEl = pluginItem.querySelector('.plugin-description');
            const btnEl = pluginItem.querySelector('.plugin-action');
            
            if (nameEl) window.i18n.translateElement(nameEl);
            if (descEl) window.i18n.translateElement(descEl);
            if (btnEl) window.i18n.translateElement(btnEl);
        }
        
        // Stagger animation
        setTimeout(() => {
            pluginItem.style.transition = 'all 0.3s cubic-bezier(0.4, 0, 0.2, 1)';
            pluginItem.style.opacity = '1';
            pluginItem.style.transform = 'translateY(0)';
        }, index * 50);
    });
}

categoryButtons.forEach(button => {
    button.addEventListener('click', () => {
        // Update active state
        categoryButtons.forEach(btn => btn.classList.remove('active'));
        button.classList.add('active');
        
        // Render plugins
        const category = button.dataset.category;
        renderPlugins(category);
    });
});

// Initial render
renderPlugins('web');

// ===========================
// Modal
// ===========================
const modal = document.getElementById('installModal');
const modalOverlay = document.getElementById('modalOverlay');
const modalClose = document.getElementById('modalClose');
const getStartedBtn = document.getElementById('getStartedBtn');
const quickInstallBtn = document.getElementById('quickInstall');
const viewDemoBtn = document.getElementById('viewDemo');

function openModal() {
    // 批量更新 DOM，减少重排
    requestAnimationFrame(() => {
        // 先隐藏 body 滚动，避免闪烁
        document.body.style.overflow = 'hidden';
        
        // 然后显示模态框
        requestAnimationFrame(() => {
            modal.classList.add('active');
        });
    });
}

function closeModal() {
    modal.classList.remove('active');
    
    // 等待动画完成后再恢复滚动
    setTimeout(() => {
        document.body.style.overflow = '';
    }, 200);
}

[getStartedBtn, quickInstallBtn].forEach(btn => {
    if (btn) {
        btn.addEventListener('click', openModal);
    }
});

modalOverlay.addEventListener('click', closeModal);
modalClose.addEventListener('click', closeModal);

// ===========================
// Smooth Scroll for Navigation
// ===========================
document.querySelectorAll('a[href^="#"]').forEach(anchor => {
    anchor.addEventListener('click', function (e) {
        const href = this.getAttribute('href');
        if (href !== '#' && href !== '') {
            e.preventDefault();
            const target = document.querySelector(href);
            if (target) {
                const offset = 72; // navbar height
                const targetPosition = target.offsetTop - offset;
                
                window.scrollTo({
                    top: targetPosition,
                    behavior: 'smooth'
                });
            }
        }
    });
});

// ===========================
// Scroll Animations
// ===========================
const animateOnScroll = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
        if (entry.isIntersecting) {
            entry.target.style.opacity = '1';
            entry.target.style.transform = 'translateY(0)';
        }
    });
}, {
    threshold: 0.1
});

// Animate feature cards, use case cards, etc.
document.querySelectorAll('.feature-card, .use-case-card, .community-card').forEach(el => {
    el.style.opacity = '0';
    el.style.transform = 'translateY(30px)';
    el.style.transition = 'all 0.6s cubic-bezier(0.4, 0, 0.2, 1)';
    animateOnScroll.observe(el);
});

// ===========================
// View Demo Button
// ===========================
if (viewDemoBtn) {
    viewDemoBtn.addEventListener('click', () => {
        const pluginsSection = document.getElementById('plugins');
        if (pluginsSection) {
            const offset = 72;
            const targetPosition = pluginsSection.offsetTop - offset;
            window.scrollTo({
                top: targetPosition,
                behavior: 'smooth'
            });
        }
    });
}

// ===========================
// Mobile Menu Toggle
// ===========================
const mobileMenuToggle = document.getElementById('mobileMenuToggle');
const navLinks = document.querySelector('.nav-links');

if (mobileMenuToggle) {
    mobileMenuToggle.addEventListener('click', () => {
        navLinks.style.display = navLinks.style.display === 'flex' ? 'none' : 'flex';
        navLinks.style.position = 'absolute';
        navLinks.style.top = '72px';
        navLinks.style.left = '0';
        navLinks.style.right = '0';
        navLinks.style.flexDirection = 'column';
        navLinks.style.background = 'var(--bg-secondary)';
        navLinks.style.padding = 'var(--spacing-md)';
        navLinks.style.borderBottom = '1px solid var(--border-color)';
    });
}

// ===========================
// Parallax Effect for Hero (高度优化)
// ===========================
if (!prefersReducedMotion && isHighPerformance) {
    let ticking = false;
    const heroVisual = document.querySelector('.hero-visual');
    const hero = document.querySelector('.hero');
    
    if (heroVisual && hero) {
        const handleParallax = () => {
            if (!ticking) {
                ticking = true;
                
                window.requestAnimationFrame(() => {
                    const scrolled = window.pageYOffset;
                    const heroRect = hero.getBoundingClientRect();
                    
                    // 仅在 hero 区域可见时才执行
                    if (heroRect.bottom > 0 && heroRect.top < window.innerHeight) {
                        // 减小视差幅度 0.2 -> 0.1
                        heroVisual.style.transform = `translate3d(0, ${scrolled * 0.1}px, 0)`;
                    }
                    
                    ticking = false;
                });
            }
        };
        
        // 使用更大的节流间隔
        const throttledParallax = throttle(handleParallax, 32); // 降低到 30fps
        window.addEventListener('scroll', throttledParallax, { passive: true });
    }
} else {
    // 低性能设备完全禁用视差
    const heroVisual = document.querySelector('.hero-visual');
    if (heroVisual) {
        heroVisual.style.transform = 'none';
    }
}

// ===========================
// Copy Modal Install Command
// ===========================
const modalCopyBtn = document.getElementById('modalCopyBtn');
if (modalCopyBtn) {
    modalCopyBtn.addEventListener('click', async () => {
        const code = document.getElementById('modalInstallCmd');
        const text = code.textContent;
        
        try {
            await navigator.clipboard.writeText(text);
            
            const originalHTML = modalCopyBtn.innerHTML;
            modalCopyBtn.innerHTML = '<svg width="18" height="18" viewBox="0 0 18 18" fill="none"><path d="M3 9L7 13L15 5" stroke="currentColor" stroke-width="2" stroke-linecap="round"/></svg>';
            modalCopyBtn.style.color = '#10b981';
            
            setTimeout(() => {
                modalCopyBtn.innerHTML = originalHTML;
                modalCopyBtn.style.color = '';
            }, 2000);
        } catch (err) {
            console.error('Failed to copy:', err);
        }
    });
}

// ===========================
// Moderator Application Modal
// ===========================
const moderatorModal = document.getElementById('moderatorModal');
const moderatorModalOverlay = document.getElementById('moderatorModalOverlay');
const moderatorModalClose = document.getElementById('moderatorModalClose');
const moderatorCard = document.getElementById('moderatorCard');
const moderatorForm = document.getElementById('moderatorForm');
const moderatorAlert = document.getElementById('moderatorAlert');

function openModeratorModal() {
    // 批量更新 DOM，减少重排
    requestAnimationFrame(() => {
        document.body.style.overflow = 'hidden';
        
        requestAnimationFrame(() => {
            moderatorModal.classList.add('active');
        });
    });
}

function closeModeratorModal() {
    moderatorModal.classList.remove('active');
    
    setTimeout(() => {
        document.body.style.overflow = '';
    }, 200);
}

if (moderatorCard) {
    moderatorCard.addEventListener('click', openModeratorModal);
}

if (moderatorModalOverlay) {
    moderatorModalOverlay.addEventListener('click', closeModeratorModal);
}

if (moderatorModalClose) {
    moderatorModalClose.addEventListener('click', closeModeratorModal);
}

// Handle moderator form submission
if (moderatorForm) {
    moderatorForm.addEventListener('submit', async (e) => {
        e.preventDefault();
        
        const formData = new FormData(moderatorForm);
        const data = Object.fromEntries(formData);
        
        // Validate required fields
        if (!data.name || !data.email || !data.category || !data.experience || !data.time || !data.motivation) {
            showModeratorAlert('请填写所有必填项（包括申请理由）', 'error');
            return;
        }
        
        // 验证字段长度
        if (data.name.trim().length < 2) {
            showModeratorAlert('姓名至少需要2个字符', 'error');
            return;
        }
        
        if (data.experience.trim().length < 10) {
            showModeratorAlert('请详细描述您的相关经验（至少10个字符）', 'error');
            return;
        }
        
        if (data.motivation.trim().length < 20) {
            showModeratorAlert('请详细说明您的申请理由（至少20个字符）', 'error');
            return;
        }
        
        // Email validation
        const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        if (!emailRegex.test(data.email)) {
            showModeratorAlert('请输入有效的邮箱地址', 'error');
            return;
        }
        
        // GitHub URL validation (if provided)
        if (data.github && data.github.trim() !== '') {
            const githubRegex = /^https?:\/\/(www\.)?github\.com\/[a-zA-Z0-9_-]+\/?$/;
            const gitlabRegex = /^https?:\/\/(www\.)?gitlab\.com\/[a-zA-Z0-9_-]+\/?$/;
            if (!githubRegex.test(data.github) && !gitlabRegex.test(data.github)) {
                showModeratorAlert('请输入有效的 GitHub 或 GitLab 个人主页链接', 'error');
                return;
            }
        }
        
        const submitBtn = document.getElementById('moderatorSubmitBtn');
        submitBtn.disabled = true;
        submitBtn.textContent = '提交中...';
        
        try {
            // 标记为版主申请，将 motivation 作为 message
            const submitData = {
                type: 'moderator',
                name: data.name,
                email: data.email,
                category: data.category,
                experience: data.experience,
                time: data.time,
                github: data.github || '',
                message: data.motivation || ''
            };
            
            const response = await fetch('/email_system.php', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify(submitData)
            });
            
            const result = await response.json();
            
            if (response.ok && result.success) {
                showModeratorAlert(result.message || '申请提交成功！我们将尽快审核您的申请。', 'success');
                moderatorForm.reset();
                
                // Auto close after 3 seconds
                setTimeout(() => {
                    closeModeratorModal();
                    setTimeout(() => {
                        moderatorAlert.style.display = 'none';
                    }, 500);
                }, 3000);
            } else {
                showModeratorAlert(result.message || '提交失败，请稍后重试', 'error');
            }
        } catch (error) {
            console.error('Submit error:', error);
            showModeratorAlert('网络错误，请检查您的连接后重试', 'error');
        } finally {
            submitBtn.disabled = false;
            submitBtn.textContent = '提交申请';
        }
    });
}

function showModeratorAlert(message, type) {
    moderatorAlert.textContent = message;
    moderatorAlert.className = `alert ${type}`;
    moderatorAlert.style.display = 'block';
    
    // Scroll to alert
    moderatorAlert.scrollIntoView({ behavior: 'smooth', block: 'nearest' });
}

// Toggle FAQ dropdown in moderator modal
function toggleModeratorFAQ(header) {
    const content = header.nextElementSibling;
    const isActive = header.classList.contains('active');
    
    header.classList.toggle('active');
    content.classList.toggle('active');
    
    const hint = header.querySelector('.dropdown-hint');
    if (hint) {
        hint.textContent = isActive ? '(点击展开)' : '(点击收起)';
    }
}

// Make function global for inline onclick
window.toggleModeratorFAQ = toggleModeratorFAQ;

// Close modals on Escape key
document.addEventListener('keydown', (e) => {
    if (e.key === 'Escape') {
        if (modal.classList.contains('active')) {
            closeModal();
        }
        if (moderatorModal.classList.contains('active')) {
            closeModeratorModal();
        }
    }
});

// ===========================
// Performance Monitor (Debug Mode)
// ===========================
if (window.location.search.includes('debug')) {
    let frameCount = 0;
    let lastTime = performance.now();
    let fps = 60;
    
    function measureFPS() {
        frameCount++;
        const now = performance.now();
        const delta = now - lastTime;
        
        if (delta >= 1000) {
            fps = Math.round((frameCount * 1000) / delta);
            frameCount = 0;
            lastTime = now;
            
            // 在控制台显示
            if (fps < 50) {
                console.warn(`⚠️ FPS: ${fps} (低于目标)`);
            }
        }
        
        requestAnimationFrame(measureFPS);
    }
    
    measureFPS();
    console.log('%c[调试模式] 性能监控已启动', 'color: #10b981; font-weight: bold');
    console.log('%c提示：在 URL 添加 ?debug 可启用调试模式', 'color: #6b7280');
}

// ===========================
// 页面滚动进度条
// ===========================
const progressBarFill = document.getElementById('progressBarFill');
const progressIndicator = document.getElementById('progressIndicator');
const progressCircle = document.getElementById('progressCircle');
const progressText = document.getElementById('progressText');

// 圆形进度条的周长
const circumference = 2 * Math.PI * 22; // r=22

function updateProgress() {
    const windowHeight = document.documentElement.scrollHeight - document.documentElement.clientHeight;
    const scrolled = window.pageYOffset;
    const progress = (scrolled / windowHeight) * 100;
    
    // 更新顶部进度条
    if (progressBarFill) {
        progressBarFill.style.width = progress + '%';
    }
    
    // 更新圆形进度指示器
    if (progressCircle && progressText) {
        const offset = circumference - (progress / 100) * circumference;
        progressCircle.style.strokeDashoffset = offset;
        progressText.textContent = Math.round(progress) + '%';
    }
    
    // 显示/隐藏返回顶部按钮
    if (progressIndicator) {
        if (scrolled > 300) {
            progressIndicator.classList.remove('hidden');
        } else {
            progressIndicator.classList.add('hidden');
        }
    }
}

// 监听滚动
window.addEventListener('scroll', throttle(updateProgress, 50), { passive: true });

// 点击返回顶部
if (progressIndicator) {
    progressIndicator.addEventListener('click', () => {
        window.scrollTo({
            top: 0,
            behavior: 'smooth'
        });
    });
}

// 初始化
updateProgress();

// ===========================
// 语言切换功能
// ===========================
document.addEventListener('DOMContentLoaded', () => {
    const languageToggle = document.getElementById('languageToggle');
    
    if (languageToggle) {
        console.log('✓ 语言切换按钮已找到，添加事件监听');
        languageToggle.addEventListener('click', (e) => {
            e.preventDefault();
            console.log('✓ 按钮被点击');
            if (typeof i18n !== 'undefined') {
                i18n.toggle();
            } else {
                console.error('✗ i18n对象未定义');
            }
        });
    } else {
        console.error('✗ 未找到语言切换按钮 #languageToggle');
    }
});

// ===========================
// Footer 联系表单
// ===========================
const footerContactForm = document.getElementById('footerContactForm');
const footerContactResult = document.getElementById('footerContactResult');

if (footerContactForm) {
    footerContactForm.addEventListener('submit', async (e) => {
        e.preventDefault();
        
        const submitBtn = footerContactForm.querySelector('button[type="submit"]');
        const originalText = submitBtn.textContent;
        
        // 禁用提交按钮
        submitBtn.disabled = true;
        submitBtn.textContent = '发送中...';
        
        // 显示加载状态
        footerContactResult.className = 'form-result show';
        footerContactResult.style.background = 'rgba(59, 130, 246, 0.1)';
        footerContactResult.style.color = '#3b82f6';
        footerContactResult.style.border = '1px solid rgba(59, 130, 246, 0.3)';
        footerContactResult.innerHTML = '<strong>⏳ 发送中...</strong><br>正在发送邮件，请稍候';
        
        // 获取表单数据
        const formData = new FormData(footerContactForm);
        const data = {
            type: 'contact',
            name: formData.get('name'),
            email: formData.get('email'),
            subject: formData.get('subject') || '网站咨询',
            message: formData.get('message')
        };
        
        try {
            const response = await fetch('/email_system.php', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify(data)
            });
            
            const result = await response.json();
            
            if (result.success) {
                footerContactResult.className = 'form-result show success';
                footerContactResult.innerHTML = '<strong>✅ 发送成功！</strong>' + 
                    (result.message || '感谢您的留言！我们已收到您的消息，将尽快回复您。');
                
                // 重置表单
                footerContactForm.reset();
                
                // 5秒后隐藏结果
                setTimeout(() => {
                    footerContactResult.classList.remove('show');
                }, 5000);
            } else {
                footerContactResult.className = 'form-result show error';
                footerContactResult.innerHTML = '<strong>❌ 发送失败</strong>' + 
                    (result.message || '邮件发送失败，请稍后重试');
            }
        } catch (error) {
            console.error('Contact form error:', error);
            footerContactResult.className = 'form-result show error';
            footerContactResult.innerHTML = '<strong>❌ 网络错误</strong>请检查网络连接后重试';
        } finally {
            submitBtn.disabled = false;
            submitBtn.textContent = originalText;
        }
    });
}

// ===========================
// Apple-Style Carousel
// ===========================
class AppleCarousel {
    constructor(containerId) {
        this.track = document.getElementById(containerId);
        if (!this.track) {
            console.error('轮播容器未找到:', containerId);
            return;
        }
        
        this.container = this.track.closest('.apple-carousel');
        this.slides = Array.from(this.track.querySelectorAll('.carousel-slide'));
        this.prevBtn = document.getElementById('carouselPrev');
        this.nextBtn = document.getElementById('carouselNext');
        this.dots = Array.from(document.querySelectorAll('.carousel-dot'));
        this.progressBar = document.getElementById('carouselProgressBar');
        
        this.currentIndex = 0;
        this.isAnimating = false;
        this.autoplayInterval = null;
        this.autoplayDuration = 5000; // 5秒自动切换
        this.progressInterval = null;
        this.currentProgress = 0; // 当前进度
        this.isPaused = false; // 是否暂停
        
        // 触摸滑动相关
        this.touchStartX = 0;
        this.touchEndX = 0;
        this.touchStartY = 0;
        this.touchEndY = 0;
        this.isDragging = false;
        
        this.init();
    }
    
    init() {
        console.log('初始化轮播，幻灯片数量:', this.slides.length);
        
        // 绑定圆点导航事件
        this.dots.forEach((dot, index) => {
            dot.addEventListener('click', () => {
                console.log('点击圆点:', index);
                this.goToSlide(index);
            });
        });
        
        // 键盘导航
        document.addEventListener('keydown', (e) => {
            if (e.key === 'ArrowLeft') this.prev();
            if (e.key === 'ArrowRight') this.next();
        });
        
        // 触摸/鼠标滑动
        this.setupTouchEvents();
        
        // 鼠标悬停暂停自动播放
        if (this.container) {
            this.container.addEventListener('mouseenter', () => {
                this.isPaused = true;
                this.pauseProgress();
            });
            this.container.addEventListener('mouseleave', () => {
                this.isPaused = false;
                this.resumeProgress();
            });
        }
        
        // Intersection Observer - 只在可见时自动播放
        const observer = new IntersectionObserver((entries) => {
            entries.forEach(entry => {
                if (entry.isIntersecting) {
                    this.startAutoplay();
                } else {
                    this.pauseAutoplay();
                }
            });
        }, { threshold: 0.5 });
        
        if (this.container) {
            observer.observe(this.container);
        }
        
        // 初始化第一张幻灯片
        this.updateSlide(0, false);
    }
    
    setupTouchEvents() {
        // 触摸事件
        this.track.addEventListener('touchstart', (e) => {
            this.touchStartX = e.touches[0].clientX;
            this.touchStartY = e.touches[0].clientY;
            this.isDragging = true;
            this.pauseAutoplay();
        }, { passive: true });
        
        this.track.addEventListener('touchmove', (e) => {
            if (!this.isDragging) return;
            this.touchEndX = e.touches[0].clientX;
            this.touchEndY = e.touches[0].clientY;
        }, { passive: true });
        
        this.track.addEventListener('touchend', () => {
            if (!this.isDragging) return;
            this.handleSwipe();
            this.isDragging = false;
            this.startAutoplay();
        });
        
        // 鼠标拖拽事件
        let mouseStartX = 0;
        let mouseEndX = 0;
        let isMouseDragging = false;
        
        this.track.addEventListener('mousedown', (e) => {
            mouseStartX = e.clientX;
            isMouseDragging = true;
            this.track.style.cursor = 'grabbing';
            this.pauseAutoplay();
            e.preventDefault();
        });
        
        document.addEventListener('mousemove', (e) => {
            if (!isMouseDragging) return;
            mouseEndX = e.clientX;
        });
        
        document.addEventListener('mouseup', () => {
            if (!isMouseDragging) return;
            
            const diff = mouseStartX - mouseEndX;
            if (Math.abs(diff) > 50) {
                if (diff > 0) {
                    this.next();
                } else {
                    this.prev();
                }
            }
            
            isMouseDragging = false;
            this.track.style.cursor = 'grab';
            this.startAutoplay();
        });
    }
    
    handleSwipe() {
        const diffX = this.touchStartX - this.touchEndX;
        const diffY = Math.abs(this.touchStartY - this.touchEndY);
        
        // 只在水平滑动大于垂直滑动时触发
        if (Math.abs(diffX) > 50 && Math.abs(diffX) > diffY) {
            if (diffX > 0) {
                this.next();
            } else {
                this.prev();
            }
        }
    }
    
    updateSlide(index, animate = true) {
        if (this.isAnimating && animate) {
            console.log('动画进行中，跳过');
            return;
        }
        
        console.log('切换到幻灯片:', index);
        
        if (animate) {
            this.isAnimating = true;
        }
        
        // 更新当前索引
        this.currentIndex = index;
        
        // 移除所有active类
        this.slides.forEach(slide => slide.classList.remove('active'));
        this.dots.forEach(dot => dot.classList.remove('active'));
        
        // 添加active类到当前幻灯片
        if (this.slides[index]) {
            this.slides[index].classList.add('active');
        }
        if (this.dots[index]) {
            this.dots[index].classList.add('active');
        }
        
        // 移动轨道
        const offset = -index * 100;
        this.track.style.transform = `translateX(${offset}%)`;
        
        // 重置进度条
        if (animate) {
            this.resetProgress();
        }
        
        // 动画完成后
        if (animate) {
            setTimeout(() => {
                this.isAnimating = false;
                console.log('动画完成');
            }, 650);
        }
    }
    
    next() {
        const nextIndex = (this.currentIndex + 1) % this.slides.length;
        console.log('下一张:', nextIndex);
        this.updateSlide(nextIndex, true);
    }
    
    prev() {
        const prevIndex = (this.currentIndex - 1 + this.slides.length) % this.slides.length;
        console.log('上一张:', prevIndex);
        this.updateSlide(prevIndex, true);
    }
    
    goToSlide(index) {
        if (index === this.currentIndex) return;
        this.updateSlide(index, true);
    }
    
    startAutoplay() {
        this.pauseAutoplay(); // 清除现有的
        
        // 启动进度条动画
        this.startProgress();
        
        // 设置自动播放
        this.autoplayInterval = setInterval(() => {
            this.next();
        }, this.autoplayDuration);
    }
    
    pauseAutoplay() {
        if (this.autoplayInterval) {
            clearInterval(this.autoplayInterval);
            this.autoplayInterval = null;
        }
        this.pauseProgress();
    }
    
    startProgress() {
        this.pauseProgress();
        this.currentProgress = 0;
        
        const increment = 100 / (this.autoplayDuration / 50); // 每50ms更新一次
        
        this.progressInterval = setInterval(() => {
            if (!this.isPaused) {
                this.currentProgress += increment;
                if (this.currentProgress >= 100) {
                    this.currentProgress = 100;
                    this.pauseProgress();
                }
                if (this.progressBar) {
                    this.progressBar.style.width = this.currentProgress + '%';
                }
            }
        }, 50);
    }
    
    pauseProgress() {
        if (this.progressInterval) {
            clearInterval(this.progressInterval);
            this.progressInterval = null;
        }
    }
    
    resumeProgress() {
        if (this.progressInterval) return; // 已经在运行
        
        const increment = 100 / (this.autoplayDuration / 50);
        
        this.progressInterval = setInterval(() => {
            if (!this.isPaused) {
                this.currentProgress += increment;
                if (this.currentProgress >= 100) {
                    this.currentProgress = 100;
                    this.pauseProgress();
                }
                if (this.progressBar) {
                    this.progressBar.style.width = this.currentProgress + '%';
                }
            }
        }, 50);
    }
    
    resetProgress() {
        this.currentProgress = 0;
        if (this.progressBar) {
            this.progressBar.style.width = '0%';
        }
        this.startProgress();
    }
}

// 初始化轮播
document.addEventListener('DOMContentLoaded', () => {
    const carouselContainer = document.querySelector('.apple-carousel');
    if (carouselContainer) {
        // 使用正确的容器ID
        const carousel = new AppleCarousel('carouselTrack');
        console.log('✓ 轮播已初始化');
    }
});

// ===========================
// Console Easter Egg
// ===========================
console.log('%c🚀 Linux Studio', 'color: #667eea; font-size: 24px; font-weight: bold;');
console.log('%c下一代Linux系统管理框架', 'color: #764ba2; font-size: 14px;');
console.log('%c想要贡献代码？访问我们的 GitHub: https://github.com/linux-studio', 'color: #a0a6b1; font-size: 12px;');
console.log('%c提示：添加 ?debug 到 URL 启用性能监控', 'color: #6b7280; font-size: 11px;');


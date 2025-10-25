/**
 * 简洁高效的双语切换系统
 * 零依赖，零网络请求，极致性能
 */

// 完整翻译映射表
const translations = {
    // 导航
    '特性': 'Features',
    '应用场景': 'Use Cases',
    '插件生态': 'Plugins',
    '开发进度': 'Progress',
    '社区': 'Community',
    '开始使用': 'Get Started',
    
    // Hero区域
    'Linux Studio': 'Linux Studio',
    '下一代Linux系统操作框架': 'Next-Gen Linux System Framework',
    '下一代Linux系统管理框架': 'Next-Gen Linux System Management Framework',
    '轻量级、模块化、强大的插件生态系统': 'Lightweight, Modular, Powerful Plugin Ecosystem',
    '轻量 · 模块化 · 强大': 'Lightweight · Modular · Powerful',
    '一个革命性的Linux系统管理框架，为开发者和系统管理员提供简单、高效、可扩展的解决方案。通过直观的API和丰富的插件系统，让系统管理变得前所未有的简单。': 'A revolutionary Linux system management framework that provides developers and system administrators with simple, efficient, and extensible solutions. With intuitive APIs and a rich plugin system, system management has never been easier.',
    '快速开始': 'Quick Start',
    '立即体验': 'Get Started',
    '立即安装': 'Install Now',
    '查看文档': 'Documentation',
    
    // Carousel 轮播图
    '强大功能展示': 'Powerful Features Showcase',
    '探索 Linux Studio 的核心能力': 'Explore the Core Capabilities of Linux Studio',
    '一键部署': 'One-Click Deployment',
    '快速部署各种服务，无需复杂配置，让开发更高效': 'Quickly deploy various services without complex configuration, making development more efficient',
    '可视化管理': 'Visual Management',
    '直观的图形界面，实时监控系统状态，轻松管理所有服务': 'Intuitive graphical interface, real-time system status monitoring, easily manage all services',
    '插件生态': 'Plugin Ecosystem',
    '丰富的插件市场，一键安装扩展功能，满足各种需求': 'Rich plugin marketplace, one-click installation of extensions, meeting various needs',
    '性能监控': 'Performance Monitoring',
    '实时性能分析，资源使用一目了然，优化系统运行': 'Real-time performance analysis, clear resource usage overview, optimize system operation',
    
    // Features 特性区域
    '为什么选择 Linux Studio': 'Why Choose Linux Studio',
    '现代化的架构，强大的功能，极致的性能': 'Modern Architecture, Powerful Features, Ultimate Performance',
    '极致轻量': 'Ultra Lightweight',
    '基于C++开发，核心框架仅数MB，启动速度快如闪电，资源占用极低': 'Built with C++, core framework is only a few MB, lightning-fast startup, minimal resource usage',
    '模块化设计': 'Modular Design',
    '插件式架构，按需加载。从Web服务器到安全工具，一键安装即用': 'Plugin-based architecture, load on demand. From web servers to security tools, install and use with one click',
    '强大生态': 'Powerful Ecosystem',
    '丰富的插件市场，活跃的社区支持。持续更新，永不过时': 'Rich plugin marketplace, active community support. Continuously updated, never outdated',
    '丰富生态': 'Rich Ecosystem',
    '框架-插件型扩展模式，社区驱动的插件市场，满足各种专业需求': 'Framework-plugin extension model, community-driven plugin marketplace, meeting various professional needs',
    '简洁 API': 'Clean API',
    '直观的命令行接口，完善的文档支持。新手友好，专家高效': 'Intuitive command-line interface, comprehensive documentation. Beginner-friendly, expert-efficient',
    '安全可靠': 'Secure & Reliable',
    '企业级安全标准，严格的代码审查。定期安全更新，保护您的系统': 'Enterprise-grade security standards, rigorous code review. Regular security updates to protect your system',
    '企业级安全': 'Enterprise Security',
    '沙箱隔离、权限管理、加密传输，保障生产环境的安全性': 'Sandbox isolation, permission management, encrypted transmission, ensuring production environment security',
    '开源免费': 'Open Source & Free',
    'MIT 许可证，完全开源。自由使用，无需授权费用': 'MIT license, fully open source. Free to use, no licensing fees',
    '高性能': 'High Performance',
    'C++原生性能，异步I/O，支持高并发场景，适合生产环境': 'Native C++ performance, asynchronous I/O, supports high concurrency scenarios, suitable for production',
    'GUI面板': 'GUI Panel',
    '现代化的Web/Hybrid/原生 GUI管理界面，直观的可视化操作，支持远程管理': 'Modern Web/Hybrid/Native GUI management interface, intuitive visual operations, supports remote management',
    
    // Use Cases 应用场景  
    '应用场景': 'Use Cases',
    '适用场景': 'Use Cases',
    '一个框架，无限可能': 'One Framework, Unlimited Possibilities',
    '适用于各种开发和运维场景': 'Suitable for Various Development and Operations Scenarios',
    'Web 开发': 'Web Development',
    'Web开发': 'Web Development',
    '开发者首选': 'Developers\' Choice',
    '快速搭建 Nginx、Apache 等Web服务器，支持PHP、Python、Node.js等多种运行环境': 'Quickly set up Nginx, Apache and other web servers, support PHP, Python, Node.js and other runtime environments',
    '性能监控与日志分析': 'Performance monitoring and log analysis',
    '数据库管理': 'Database Management',
    '一键部署 MySQL、PostgreSQL、MongoDB 等数据库，图形化管理界面': 'One-click deployment of MySQL, PostgreSQL, MongoDB and other databases, graphical management interface',
    '容器编排': 'Container Orchestration',
    '集成 Docker、Kubernetes 管理工具，简化容器部署和维护': 'Integrated Docker, Kubernetes management tools, simplify container deployment and maintenance',
    '安全测试': 'Security Testing',
    '网络安全': 'Network Security',
    '白帽专用': 'For White Hat',
    '内置常用安全工具，支持渗透测试、漏洞扫描等安全审计功能': 'Built-in common security tools, support penetration testing, vulnerability scanning and other security audit functions',
    'Wireshark、Nmap 工具链': 'Wireshark, Nmap toolkit',
    '渗透测试工具集成': 'Penetration testing tool integration',
    '流量分析与监控': 'Traffic analysis and monitoring',
    '漏洞扫描自动化': 'Automated vulnerability scanning',
    '安全日志审计': 'Security log auditing',
    '机器人开发': 'Robot Development',
    'ROS生态': 'ROS Ecosystem',
    'ROS2 一键部署': 'ROS2 one-click deployment',
    '机器人控制服务器': 'Robot control server',
    '传感器数据管理': 'Sensor data management',
    '实时通信支持': 'Real-time communication support',
    '仿真环境配置': 'Simulation environment configuration',
    'DevOps 自动化': 'DevOps Automation',
    'DevOps': 'DevOps',
    '运维利器': 'DevOps Tool',
    '支持 CI/CD 流程，自动化部署，集成 Git、Jenkins 等工具': 'Support CI/CD processes, automated deployment, integration with Git, Jenkins and other tools',
    'CI/CD 流水线管理': 'CI/CD pipeline management',
    'Docker、K8s 容器编排': 'Docker, K8s container orchestration',
    '多服务器集群管理': 'Multi-server cluster management',
    '监控告警系统': 'Monitoring and alerting system',
    '系统监控': 'System Monitoring',
    '实时监控服务器状态，性能分析，日志管理，告警通知': 'Real-time server status monitoring, performance analysis, log management, alert notifications',
    'Developing...': 'Developing...',
    '组件可拓展性，可维护性，可持续发展性': 'Component scalability, maintainability, sustainability',
    '更多SDK,工具链即将接入': 'More SDKs and toolchains coming soon',
    '敬请期待...': 'Stay tuned...',
    
    // Quick Start 快速开始
    '快速开始': 'Quick Start',
    '三步完成安装，立即开始使用': 'Complete installation in three steps, start using immediately',
    '安装核心框架': 'Install Core Framework',
    '使用一行命令自动安装Linux Studio核心框架': 'Automatically install Linux Studio core framework with one command',
    '安装Web面板': 'Install Web Panel',
    '通过交互式命令安装可视化管理面板': 'Install visual management panel through interactive commands',
    '安装所需插件': 'Install Required Plugins',
    '从插件市场选择并安装你需要的工具和服务': 'Select and install the tools and services you need from the plugin marketplace',
    '查看完整文档': 'View Full Documentation',
    
    // Code 代码示例
    'installation.sh': 'installation.sh',
    '# 下载并安装 Linux Studio': '# Download and install Linux Studio',
    '# 启动 Linux Studio': '# Start Linux Studio',
    '# 安装 Web 面板': '# Install Web panel',
    '# 安装插件（例如：Nginx）': '# Install plugin (e.g., Nginx)',
    '✓ Nginx 安装成功': '✓ Nginx installed successfully',
    '✓ 服务已启动于 http://localhost:80': '✓ Service started at http://localhost:80',
    
    // Use Cases Features 功能列表
    '一键部署 Nginx、Apache': 'One-click deployment of Nginx, Apache',
    'Redis、MySQL 数据库管理': 'Redis, MySQL database management',
    'SSL证书自动化': 'SSL certificate automation',
    '文件管理与备份': 'File management and backup',
    '完善的日志系统': 'Comprehensive logging system',
    '性能监控面板': 'Performance monitoring dashboard',
    '数据库可视化管理': 'Database visual management',
    '自动备份与恢复': 'Automatic backup and recovery',
    '支持 MySQL、PostgreSQL、MongoDB': 'Support MySQL, PostgreSQL, MongoDB',
    '一键创建数据库和用户': 'One-click database and user creation',
    'Docker 容器管理': 'Docker container management',
    'Kubernetes 集群部署': 'Kubernetes cluster deployment',
    '镜像构建与推送': 'Image building and pushing',
    '容器监控与日志': 'Container monitoring and logging',
    'Wireshark 抓包分析': 'Wireshark packet analysis',
    'Nmap 端口扫描': 'Nmap port scanning',
    'Metasploit 渗透测试': 'Metasploit penetration testing',
    '漏洞扫描工具集': 'Vulnerability scanning toolkit',
    'Git 版本控制': 'Git version control',
    'CI/CD 流水线': 'CI/CD pipeline',
    '自动化部署脚本': 'Automated deployment scripts',
    '集成 Jenkins、GitLab': 'Integration with Jenkins, GitLab',
    '实时资源监控': 'Real-time resource monitoring',
    'CPU、内存、磁盘分析': 'CPU, memory, disk analysis',
    '告警与通知': 'Alerts and notifications',
    '日志聚合分析': 'Log aggregation and analysis',
    
    // Plugins 插件生态
    '插件生态系统': 'Plugin Ecosystem',
    '强大的扩展能力': 'Powerful Extensibility',
    '数百个高质量插件，满足各种需求': 'Hundreds of High-Quality Plugins to Meet Various Needs',
    
    // Plugin Categories 插件分类
    'Web服务': 'Web Services',
    '数据库': 'Database',
    '安全工具': 'Security Tools',
    '开发工具': 'Dev Tools',
    '监控分析': 'Monitoring',
    
    // Plugin Names 插件名称
    // Web Services
    'Nginx': 'Nginx',
    '高性能Web服务器和反向代理': 'High-performance web server and reverse proxy',
    'Apache': 'Apache',
    '功能强大的HTTP服务器': 'Powerful HTTP server',
    'Node.js': 'Node.js',
    'JavaScript运行时环境': 'JavaScript runtime environment',
    'PHP': 'PHP',
    'PHP运行环境和扩展管理': 'PHP runtime and extension management',
    'Caddy': 'Caddy',
    '自动HTTPS的现代Web服务器': 'Modern web server with automatic HTTPS',
    
    // Database
    'MySQL': 'MySQL',
    '流行的关系型数据库': 'Popular relational database',
    'PostgreSQL': 'PostgreSQL',
    '先进的开源关系型数据库': 'Advanced open-source relational database',
    'Redis': 'Redis',
    '内存数据结构存储': 'In-memory data structure store',
    'MongoDB': 'MongoDB',
    'NoSQL文档数据库': 'NoSQL document database',
    'Elasticsearch': 'Elasticsearch',
    '分布式搜索和分析引擎': 'Distributed search and analytics engine',
    
    // Security Tools
    'Wireshark': 'Wireshark',
    '网络协议分析工具': 'Network protocol analyzer',
    'Nmap': 'Nmap',
    '网络发现和安全审计': 'Network discovery and security auditing',
    'OpenSSL': 'OpenSSL',
    'SSL/TLS加密工具包': 'SSL/TLS cryptography toolkit',
    'Fail2ban': 'Fail2ban',
    '入侵防御软件': 'Intrusion prevention software',
    'ClamAV': 'ClamAV',
    '开源防病毒引擎': 'Open-source antivirus engine',
    
    // Development Tools
    'Docker': 'Docker',
    '容器化平台': 'Containerization platform',
    'Kubernetes': 'Kubernetes',
    '容器编排系统': 'Container orchestration system',
    'Git': 'Git',
    '版本控制系统': 'Version control system',
    'Jenkins': 'Jenkins',
    'CI/CD自动化服务器': 'CI/CD automation server',
    'ROS2': 'ROS2',
    '机器人操作系统': 'Robot Operating System',
    
    // Monitoring Tools
    'Grafana': 'Grafana',
    '可视化和分析平台': 'Visualization and analytics platform',
    'Prometheus': 'Prometheus',
    '监控和告警工具包': 'Monitoring and alerting toolkit',
    'ELK Stack': 'ELK Stack',
    '日志分析解决方案': 'Log analysis solution',
    'Zabbix': 'Zabbix',
    '企业级监控解决方案': 'Enterprise monitoring solution',
    'Netdata': 'Netdata',
    '实时性能监控': 'Real-time performance monitoring',
    
    '系统监控': 'System Monitor',
    '实时监控系统资源使用情况': 'Real-time system resource monitoring',
    '网络工具': 'Network Tools',
    '完整的网络诊断和管理工具集': 'Complete network diagnostic and management toolkit',
    '安全防护': 'Security Protection',
    '防火墙、入侵检测等安全功能': 'Firewall, intrusion detection and other security features',
    '数据备份': 'Data Backup',
    '自动化备份和恢复解决方案': 'Automated backup and recovery solutions',
    '下载': 'Downloads',
    '查看全部插件': 'View All Plugins',
    '安装': 'Install',
    
    // Progress 开发进度
    '项目开发进度': 'Development Progress',
    'Linux Studio 正在积极开发中，敬请期待': 'Linux Studio is under active development, stay tuned',
    '总体进度': 'Overall Progress',
    '核心模块': 'Core Modules',
    '插件开发': 'Plugin Development',
    '文档完成度': 'Documentation',
    '核心框架开发': 'Core Framework',
    'Web 管理面板': 'Web Panel',
    '插件系统': 'Plugin System',
    'API 文档': 'API Documentation',
    '测试与优化': 'Testing & Optimization',
    '开发说明：': 'Development Note:',
    '开发说明：项目目前处于早期阶段，我们正在积极构建核心功能。预计首个 Alpha 版本将在 2025 年发布。': 'Development Note: The project is currently in its early stages, and we are actively building core features. The first Alpha version is expected to be released in 2025.',
    '项目目前处于早期阶段，我们正在积极构建核心功能。预计首个 Alpha 版本将在 2025 年发布。': 'The project is currently in its early stages, and we are actively building core features. The first Alpha version is expected to be released in 2025.',
    '想要参与开发？': 'Want to participate in development?',
    '想要参与开发？加入我们的社区 或 申请成为版主。': 'Want to participate in development? Join our community or apply to become a moderator.',
    '加入我们的社区': 'Join our community',
    '或': 'or',
    '申请成为版主': 'Apply to become a moderator',
    '准备好开始了吗？': 'Ready to Get Started?',
    '立即安装 Linux Studio，体验下一代 Linux 系统管理': 'Install Linux Studio now and experience next-gen Linux system management',
    '立即安装': 'Install Now',
    '核心框架': 'Core Framework',
    '已完成': 'Completed',
    '插件系统': 'Plugin System',
    '开发中': 'In Progress',
    'Web 界面': 'Web Interface',
    '规划中': 'Planned',
    'API 文档': 'API Documentation',
    
    // Community 社区
    '加入社区': 'Join Community',
    '加入我们的Community': 'Join Our Community',
    '加入我们的社区': 'Join Our Community',
    '与全球开发者一起构建更好的生态': 'Build a Better Ecosystem with Global Developers',
    '与全球开发者一起，构建更好的工具': 'Build Better Tools with Developers Worldwide',
    'Ready to Get Started?': 'Ready to Get Started?',
    'Install Linux Studio now and experience next-gen Linux system management': 'Install Linux Studio now and experience next-gen Linux system management',
    'Become a Moderator': 'Become a Moderator',
    'GitHub': 'GitHub',
    '查看源码，参与贡献': 'View source code, contribute',
    '在 GitHub 上关注我们': 'Follow Us on GitHub',
    '查看源代码，提交问题和 PR': 'View source code, submit issues and PRs',
    'Discord': 'Discord',
    '实时交流，获取帮助': 'Real-time chat, get help',
    '加入讨论，获取支持': 'Join discussions, get support',
    '加入 Discord': 'Join Discord',
    '与社区成员实时交流': 'Chat with community members in real-time',
    '论坛': 'Forum',
    '文档中心': 'Documentation',
    '详细教程，API文档': 'Tutorials and API docs',
    '插件市场': 'Plugin Market',
    '发布你的插件': 'Publish your plugins',
    '访问论坛': 'Visit Forum',
    '在论坛获取帮助和分享经验': 'Get help and share experience on the forum',
    '加入开发者': 'Join Developers',
    '负责板块源、版本更新': 'Manage sections and updates',
    '申请成为版主': 'Become a Moderator',
    '帮助管理社区，获得特殊权限': 'Help manage the community, get special privileges',
    '给予赞助支持': 'Support Us',
    '本项目为免费项目，请自愿捐赠，这是我们开发的动力之一': 'This is a free project, voluntary donations are our motivation',
    '立即申请': 'Apply Now',
    
    // Moderator Form 版主申请表单
    '申请成为社区版主': 'Apply to Become a Community Moderator',
    '感谢您愿意为 Linux Studio 社区贡献力量！版主将负责特定板块的源维护、版本更新等工作。': 'Thank you for your willingness to contribute to the Linux Studio community! Moderators will be responsible for source maintenance, version updates, etc. for specific sections.',
    
    // Form Fields 表单字段
    '姓名 / 昵称 *': 'Name / Nickname *',
    'Name / 昵称 *': 'Name / Nickname *',
    '请输入您的姓名或昵称': 'Enter your name or nickname',
    '邮箱地址 *': 'Email Address *',
    'Email地址 *': 'Email Address *',
    '申请板块 *': 'Section *',
    '相关经验 *': 'Experience *',
    '请简要介绍您在该领域的经验和技能...': 'Please briefly describe your experience and skills in this field...',
    '可投入时间（每周）*': 'Time Commitment (per week) *',
    'Time Commitment（每周）*': 'Time Commitment (per week) *',
    '请选择每周可投入的时间': 'Select your weekly time commitment',
    'GitHub / GitLab 个人主页': 'GitHub / GitLab Profile',
    'GitHub / GitLab Profile': 'GitHub / GitLab Profile',
    'https://github.com/yourusername': 'https://github.com/yourusername',
    '申请理由 *': 'Reason *',
    '为什么想成为版主？您能为社区带来什么？（至少20字）': 'Why do you want to be a moderator? What can you bring to the community? (min 20 chars)',
    '提交申请': 'Submit Application',
    'Submit Application': 'Submit Application',
    'Moderator Responsibilities:': 'Moderator Responsibilities:',
    
    // Moderator Responsibilities 版主职责
    '版主职责：': 'Moderator Responsibilities:',
    '维护所负责板块的插件源和文档': 'Maintain plugin sources and documentation for your section',
    '审核和测试插件更新': 'Review and test plugin updates',
    '协助用户解决相关问题': 'Help users solve related issues',
    '参与社区建设和发展规划': 'Participate in community building and development planning',
    
    // FAQ 常见问题
    'Q: 版主有报酬吗？': 'Q: Are moderators paid?',
    'A: 目前为志愿者性质，但优秀版主将获得社区认证和优先体验新功能的权限。': 'A: Currently volunteer-based, but outstanding moderators will receive community certification and priority access to new features.',
    'Q: 需要什么技术水平？': 'Q: What technical level is required?',
    'A: 需要熟悉所申请板块的相关技术，能够独立解决常见问题。': 'A: Familiarity with relevant technologies in the applied section and ability to independently solve common problems.',
    'Q: 审核需要多长时间？': 'Q: How long does the review take?',
    'A: 通常在1-3个工作日内给予反馈。': 'A: Feedback is usually provided within 1-3 business days.',
    'Q: 可以申请多个板块吗？': 'Q: Can I apply for multiple sections?',
    'A: 建议先专注一个板块，表现优秀后可申请更多。': 'A: It is recommended to focus on one section first, and apply for more after excellent performance.',
    
    '请填写所有必填项': 'Please fill in all required fields',
    '请选择您想负责的板块': 'Please select the section you want to manage',
    'Web服务 (Nginx, Apache, Node.js等)': 'Web Services (Nginx, Apache, Node.js, etc.)',
    '数据库 (MySQL, Redis, MongoDB等)': 'Database (MySQL, Redis, MongoDB, etc.)',
    '安全工具 (Wireshark, Nmap等)': 'Security Tools (Wireshark, Nmap, etc.)',
    '开发工具 (Docker, K8s, ROS2等)': 'Development Tools (Docker, K8s, ROS2, etc.)',
    '相关经验（至少10个字符）': 'Related Experience (min 10 characters)',
    '请简要描述您的相关经验': 'Please briefly describe your relevant experience',
    '可投入时间': 'Time Commitment',
    '例如：每周10小时': 'e.g., 10 hours per week',
    'GitHub/GitLab地址': 'GitHub/GitLab URL',
    '申请理由（至少20个字符）': 'Reason for Application (min 20 characters)',
    '请说明您为什么想成为版主': 'Please explain why you want to be a moderator',
    '提交': 'Submit',
    
    // 联系表单
    '联系我们': 'Contact Us',
    '有任何问题或建议？欢迎与我们取得联系': 'Have any questions or suggestions? Feel free to reach out',
    '姓名': 'Name',
    '邮箱': 'Email',
    '主题': 'Subject',
    '消息内容': 'Message',
    '发送消息': 'Send Message',
    '请输入您的姓名': 'Enter your name',
    '简要描述您的问题': 'Brief description',
    '详细描述您的问题或建议...': 'Detailed description...',
    
    // Footer 页脚
    '下一代Linux系统管理框架': 'Next-Gen Linux System Management Framework',
    '轻量 · 模块化 · 强大': 'Lightweight · Modular · Powerful',
    'Linux Studio 是一个现代化的Linux系统管理框架，致力于简化系统运维工作。': 'Linux Studio is a modern Linux system management framework dedicated to simplifying system operations.',
    'Product': 'Product',
    '产品': 'Product',
    'Features': 'Features',
    '功能特性': 'Features',
    '插件': 'Plugins',
    '插件市场': 'Plugin Market',
    '定价': 'Pricing',
    'Documentation': 'Documentation',
    '更新日志': 'Changelog',
    'Changelog': 'Changelog',
    'Resources': 'Resources',
    '资源': 'Resources',
    '文档': 'Documentation',
    'API文档': 'API Docs',
    'API 参考': 'API Reference',
    '开发指南': 'Dev Guide',
    '插件开发': 'Plugin Development',
    '最佳实践': 'Best Practices',
    '示例代码': 'Examples',
    '博客': 'Blog',
    'Blog': 'Blog',
    'Community': 'Community',
    '支持': 'Support',
    '帮助中心': 'Help Center',
    '贡献指南': 'Contributing',
    '系统状态': 'System Status',
    '隐私政策': 'Privacy Policy',
    '关于': 'About',
    '团队': 'Team',
    'Team': 'Team',
    'Contact Us': 'Contact Us',
    '© 2024 Linux Studio. 保留所有权利。': '© 2024 Linux Studio. All rights reserved.',
    '© 2025 Linux Studio. Presented by 小恐龙工作室. All rights reserved. Built with ❤️ by the community.': '© 2025 Linux Studio. Presented by Dino Studio. All rights reserved. Built with ❤️ by the community.',
    
    // 状态消息
    '发送中...': 'Sending...',
    '发送成功！': 'Success!',
    '感谢您的留言！我们已收到您的消息，将尽快回复您。': 'Thank you! We have received your message and will reply soon.',
    '发送失败': 'Failed',
};

class SimpleI18n {
    constructor() {
        this.currentLang = localStorage.getItem('lang') || 'zh';
        this.elements = new Map();
    }
    
    // 初始化 - 收集需要翻译的元素
    init() {
        // 自动为可翻译元素添加标记
        this.autoMarkElements();
        
        const elements = document.querySelectorAll('[data-translate]');
        console.log('找到需要翻译的元素:', elements.length);
        
        elements.forEach(el => {
            const originalText = el.textContent.trim() || el.placeholder;
            if (originalText) {
                this.elements.set(el, {
                    zh: originalText,
                    en: translations[originalText] || originalText
                });
            }
        });
        
        console.log('已收集翻译映射:', this.elements.size);
        
        // 更新UI（无论当前语言是什么）
        this.updateUI();
        
        // 如果保存的是英文，立即切换
        if (this.currentLang === 'en') {
            this.switchToEnglish();
        }
    }
    
    // 自动为元素添加翻译标记
    autoMarkElements() {
        // 需要翻译的选择器列表
        const selectors = [
            '.section-title',
            '.section-description',
            '.feature-title',
            '.feature-description',
            '.feature-tag',
            '.use-case-title',
            '.use-case-description',
            '.use-case-features li',
            '.use-case-tag',
            '.plugin-category',
            '.plugin-name',
            '.plugin-description',
            '.plugin-tag',
            '.timeline-title',
            '.timeline-status',
            '.timeline-description',
            '.progress-item h4',
            '.progress-item p',
            '.progress-label',
            '.progress-item-title',
            '.stat-label',
            '.progress-note',
            '.dev-note',
            '.community-title',
            '.community-description',
            '.community-card h3',
            '.community-card p',
            '.community-tag',
            '.footer-description',
            '.footer-title',
            '.footer-links a',
            '.footer-bottom p',
            '.footer-logo + p',
            '.stats-number',
            '.stats-label',
            '.step-content h4',
            '.step-content p',
            '.btn',
            '.code-title',
            '.cta-title',
            '.cta-description',
            'option',
            'label',
            'h1', 'h2', 'h3', 'h4', 'h5'
        ];
        
        selectors.forEach(selector => {
            document.querySelectorAll(selector).forEach(el => {
                // 跳过已标记的、空的、或包含SVG的元素
                if (el.hasAttribute('data-translate') || !el.textContent.trim() || el.querySelector('svg')) {
                    return;
                }
                // 跳过只包含 .required 的标签（这些由父元素处理）
                if (el.classList.contains('required')) {
                    return;
                }
                el.setAttribute('data-translate', '');
            });
        });
        
        // 特殊处理：代码注释
        document.querySelectorAll('.comment').forEach(el => {
            if (el.textContent.trim() && !el.hasAttribute('data-translate')) {
                el.setAttribute('data-translate', '');
            }
        });
        
        // 特殊处理：输出文本
        document.querySelectorAll('.output').forEach(el => {
            if (el.textContent.trim() && !el.hasAttribute('data-translate')) {
                el.setAttribute('data-translate', '');
            }
        });
    }
    
    // 切换到英文
    switchToEnglish() {
        this.elements.forEach((texts, el) => {
            if (el.tagName === 'INPUT' || el.tagName === 'TEXTAREA') {
                if (el.placeholder) el.placeholder = texts.en;
            } else {
                // 保留子元素（如链接、强调标签）的HTML结构
                if (el.children.length > 0) {
                    // 如果有子元素，尝试替换整个内部HTML或仅文本节点
                    const htmlEn = this.translateHTML(el.innerHTML, 'en');
                    if (htmlEn) {
                        el.innerHTML = htmlEn;
                    }
                } else {
                    el.textContent = texts.en;
                }
            }
        });
        
        this.currentLang = 'en';
        this.updateUI();
    }
    
    // 切换到中文
    switchToChinese() {
        this.elements.forEach((texts, el) => {
            if (el.tagName === 'INPUT' || el.tagName === 'TEXTAREA') {
                if (el.placeholder) el.placeholder = texts.zh;
            } else {
                // 保留子元素（如链接、强调标签）的HTML结构
                if (el.children.length > 0) {
                    const htmlZh = this.translateHTML(el.innerHTML, 'zh');
                    if (htmlZh) {
                        el.innerHTML = htmlZh;
                    }
                } else {
                    el.textContent = texts.zh;
                }
            }
        });
        
        this.currentLang = 'zh';
        this.updateUI();
    }
    
    // 翻译HTML内容（保留标签结构）
    translateHTML(html, lang) {
        let result = html;
        
        // 将翻译条目按长度排序（从长到短），避免部分匹配问题
        const entries = Object.entries(translations).sort((a, b) => {
            const keyA = lang === 'en' ? a[0] : a[1];
            const keyB = lang === 'en' ? b[0] : b[1];
            return keyB.length - keyA.length;
        });
        
        // 遍历翻译字典，替换文本内容
        for (let [zh, en] of entries) {
            if (lang === 'en') {
                // 中文 -> 英文
                result = result.replace(new RegExp(this.escapeRegex(zh), 'g'), en);
            } else {
                // 英文 -> 中文
                result = result.replace(new RegExp(this.escapeRegex(en), 'g'), zh);
            }
        }
        
        return result !== html ? result : null;
    }
    
    // 转义正则表达式特殊字符
    escapeRegex(str) {
        return str.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
    }
    
    // 翻译单个元素（用于动态添加的元素）
    translateElement(el) {
        const text = el.textContent.trim() || el.placeholder;
        if (!text) return;
        
        const translated = this.currentLang === 'en' 
            ? (translations[text] || text)
            : text;
        
        if (el.tagName === 'INPUT' || el.tagName === 'TEXTAREA') {
            if (el.placeholder) el.placeholder = translated;
        } else {
            if (el.children.length > 0) {
                const htmlTranslated = this.translateHTML(el.innerHTML, this.currentLang);
                if (htmlTranslated) {
                    el.innerHTML = htmlTranslated;
                }
            } else {
                el.textContent = translated;
            }
        }
    }
    
    // 切换语言
    toggle() {
        console.log('切换语言，当前:', this.currentLang);
        
        if (this.currentLang === 'zh') {
            this.switchToEnglish();
        } else {
            this.switchToChinese();
        }
        
        // 保存偏好
        localStorage.setItem('lang', this.currentLang);
        
        console.log('切换后:', this.currentLang);
        
        // 重新渲染插件（如果存在）
        if (typeof renderPlugins === 'function') {
            const activeCategory = document.querySelector('.plugin-category.active');
            if (activeCategory) {
                const category = activeCategory.dataset.category;
                renderPlugins(category);
            }
        }
    }
    
    // 更新UI元素
    updateUI() {
        // 更新语言按钮
        const langBtn = document.querySelector('.lang-text');
        if (langBtn) {
            langBtn.textContent = this.currentLang === 'zh' ? 'EN' : '中';
        }
        
        // 更新页面标题
        document.title = this.currentLang === 'zh' 
            ? 'Linux Studio - 下一代Linux系统操作框架'
            : 'Linux Studio - Next-Gen Linux System Framework';
        
        // 更新HTML lang属性
        document.documentElement.lang = this.currentLang === 'zh' ? 'zh-CN' : 'en';
    }
}

// 创建全局实例
const i18n = new SimpleI18n();

// 确保DOM完全加载后再初始化
document.addEventListener('DOMContentLoaded', () => {
    console.log('DOM加载完成，开始初始化i18n');
    i18n.init();
    console.log('翻译系统初始化完成，当前语言:', i18n.currentLang);
    
    // 如果当前语言是英文，等待插件渲染完成后翻译
    if (i18n.currentLang === 'en') {
        setTimeout(() => {
            const activeCategory = document.querySelector('.plugin-category.active');
            if (activeCategory && typeof renderPlugins === 'function') {
                const category = activeCategory.dataset.category;
                renderPlugins(category);
            }
        }, 100);
    }
});


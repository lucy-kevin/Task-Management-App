import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:task_management_app/screens/profile_screen.dart';
import 'package:task_management_app/services/auth_services.dart';
import 'package:task_management_app/services/task_services.dart';
import 'package:task_management_app/widgets/add_card.dart';
import 'package:task_management_app/widgets/stat_card.dart';

import '../../widgets/task_card.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

    // Load tasks when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final taskService = Provider.of<TaskService>(context, listen: false);
      taskService.loadTasks();
      taskService.startListening();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final taskService = Provider.of<TaskService>(context);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.task_alt, color: Colors.white),
            SizedBox(width: 8),
            Text('Task Manager'),
          ],
        ),
        actions: [
          // Filter Menu
          PopupMenuButton<String>(
            icon: Icon(Icons.filter_list),
            onSelected: (value) {
              taskService.setFilter(value);
            },
            itemBuilder: (context) => [
              PopupMenuItem(value: 'all', child: Text('All Tasks')),
              PopupMenuItem(value: 'pending', child: Text('Pending')),
              PopupMenuItem(value: 'completed', child: Text('Completed')),
            ],
          ),

          // Sort Menu
          PopupMenuButton<String>(
            icon: Icon(Icons.sort),
            onSelected: (value) {
              taskService.setSortBy(value);
            },
            itemBuilder: (context) => [
              PopupMenuItem(value: 'createdAt', child: Text('Date Created')),
              PopupMenuItem(value: 'dueDate', child: Text('Due Date')),
              PopupMenuItem(value: 'priority', child: Text('Priority')),
              PopupMenuItem(value: 'title', child: Text('Title')),
            ],
          ),

          // Profile Menu
          PopupMenuButton<String>(
            icon: CircleAvatar(
              radius: 16,
              backgroundColor: Colors.white,
              child: Text(
                authService.currentUser?.displayName
                        ?.substring(0, 1)
                        .toUpperCase() ??
                    'U',
                style: TextStyle(
                  color: Colors.blue[700],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            onSelected: (value) async {
              switch (value) {
                case 'profile':
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ProfileScreen()),
                  );
                  break;
                case 'logout':
                  await authService.signOut();
                  break;
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'profile',
                child: Row(
                  children: [
                    Icon(Icons.person, size: 20),
                    SizedBox(width: 8),
                    Text('Profile'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, size: 20),
                    SizedBox(width: 8),
                    Text('Logout'),
                  ],
                ),
              ),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: [
            Tab(text: 'All'),
            Tab(text: 'Pending'),
            Tab(text: 'Completed'),
            Tab(text: 'Stats'),
          ],
        ),
      ),

      body: Column(
        children: [
          // Welcome Section
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue[700]!, Colors.blue[500]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome back,',
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
                Text(
                  authService.currentUser?.displayName ?? 'User',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Consumer<TaskService>(
                  builder: (context, taskService, child) {
                    final stats = taskService.getTaskStats();
                    return Text(
                      'You have ${stats['pending']} pending tasks',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    );
                  },
                ),
              ],
            ),
          ),

          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTaskList(taskService, 'all'),
                _buildTaskList(taskService, 'pending'),
                _buildTaskList(taskService, 'completed'),
                _buildStatsTab(taskService),
              ],
            ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddTaskScreen()),
          );
        },
        child: Icon(Icons.add),
        tooltip: 'Add Task',
      ),
    );
  }

  Widget _buildTaskList(TaskService taskService, String filter) {
    return Consumer<TaskService>(
      builder: (context, taskService, child) {
        if (taskService.isLoading) {
          return Center(child: CircularProgressIndicator());
        }

        final tasks = filter == 'all'
            ? taskService.filteredTasks
            : taskService.filteredTasks
                  .where((task) => task.status == filter)
                  .toList();

        if (tasks.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.task_alt, size: 64, color: Colors.grey[400]),
                SizedBox(height: 16),
                Text(
                  filter == 'all' ? 'No tasks yet' : 'No ${filter} tasks',
                  style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                ),
                SizedBox(height: 8),
                Text(
                  'Tap the + button to create your first task',
                  style: TextStyle(color: Colors.grey[500]),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => taskService.loadTasks(),
          child: ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              return TaskCard(
                task: task,
                onTap: () => _showTaskDetails(task),
                onToggle: () => taskService.toggleTaskStatus(task.id),
                onDelete: () => _showDeleteConfirmation(task),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildStatsTab(TaskService taskService) {
    return Consumer<TaskService>(
      builder: (context, taskService, child) {
        final stats = taskService.getTaskStats();

        return SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Task Statistics',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),

              // Stats Cards
              Row(
                children: [
                  Expanded(
                    child: StatsCard(
                      title: 'Total Tasks',
                      value: stats['total'].toString(),
                      icon: Icons.task,
                      color: Colors.blue,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: StatsCard(
                      title: 'Pending',
                      value: stats['pending'].toString(),
                      icon: Icons.pending_actions,
                      color: Colors.orange,
                    ),
                  ),
                ],
              ),

              SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: StatsCard(
                      title: 'Completed',
                      value: stats['completed'].toString(),
                      icon: Icons.check_circle,
                      color: Colors.green,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: StatsCard(
                      title: 'Overdue',
                      value: stats['overdue'].toString(),
                      icon: Icons.warning,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),

              SizedBox(height: 24),

              // Completion Rate
              if (stats['total']! > 0) ...[
                Text(
                  'Completion Rate',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.trending_up, color: Colors.green[700]),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${((stats['completed']! / stats['total']!) * 100).toStringAsFixed(1)}%',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.green[700],
                              ),
                            ),
                            Text(
                              'Tasks completed',
                              style: TextStyle(color: Colors.green[600]),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  void _showTaskDetails(task) {
    // Navigate to task details screen
    // Implementation depends on your task details screen
  }

  void _showDeleteConfirmation(task) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Task'),
        content: Text('Are you sure you want to delete "${task.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Provider.of<TaskService>(
                context,
                listen: false,
              ).deleteTask(task.id);
              Navigator.pop(context);
            },
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:task_management_app/models/task_model.dart';

class TaskService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<Task> _tasks = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _filterStatus = 'all';
  String _sortBy = 'createdAt';

  List<Task> get tasks => _tasks;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get filterStatus => _filterStatus;
  String get sortBy => _sortBy;

  // Get filtered and sorted tasks
  List<Task> get filteredTasks {
    List<Task> filtered = _tasks;

    // Apply status filter
    if (_filterStatus != 'all') {
      filtered = filtered
          .where((task) => task.status == _filterStatus)
          .toList();
    }

    // Apply sorting
    switch (_sortBy) {
      case 'dueDate':
        filtered.sort((a, b) => a.dueDate.compareTo(b.dueDate));
        break;
      case 'priority':
        final priorityOrder = {'high': 0, 'medium': 1, 'low': 2};
        filtered.sort(
          (a, b) =>
              priorityOrder[a.priority]!.compareTo(priorityOrder[b.priority]!),
        );
        break;
      case 'title':
        filtered.sort((a, b) => a.title.compareTo(b.title));
        break;
      default:
        filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }

    return filtered;
  }

  // Load tasks for current user
  Future<void> loadTasks() async {
    if (_auth.currentUser == null) return;

    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final QuerySnapshot snapshot = await _firestore
          .collection('tasks')
          .where('userId', isEqualTo: _auth.currentUser!.uid)
          .orderBy('createdAt', descending: true)
          .get();

      _tasks = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Task.fromFirestore(doc.id, data);
      }).toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load tasks';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add new task
  Future<bool> addTask(Task task) async {
    if (_auth.currentUser == null) return false;

    try {
      _errorMessage = null;

      final taskData = task.toFirestore();
      taskData['userId'] = _auth.currentUser!.uid;

      final DocumentReference docRef = await _firestore
          .collection('tasks')
          .add(taskData);

      final newTask = Task(
        id: docRef.id,
        title: task.title,
        description: task.description,
        userId: _auth.currentUser!.uid,
        status: task.status,
        priority: task.priority,
        dueDate: task.dueDate,
        createdAt: task.createdAt,
        updatedAt: task.updatedAt,
      );

      _tasks.insert(0, newTask);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to add task';
      notifyListeners();
      return false;
    }
  }

  // Update task
  Future<bool> updateTask(Task task) async {
    try {
      _errorMessage = null;

      final updatedTask = task.copyWith(updatedAt: DateTime.now());

      await _firestore
          .collection('tasks')
          .doc(task.id)
          .update(updatedTask.toFirestore());

      final index = _tasks.indexWhere((t) => t.id == task.id);
      if (index != -1) {
        _tasks[index] = updatedTask;
        notifyListeners();
      }

      return true;
    } catch (e) {
      _errorMessage = 'Failed to update task';
      notifyListeners();
      return false;
    }
  }

  // Delete task
  Future<bool> deleteTask(String taskId) async {
    try {
      _errorMessage = null;

      await _firestore.collection('tasks').doc(taskId).delete();

      _tasks.removeWhere((task) => task.id == taskId);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete task';
      notifyListeners();
      return false;
    }
  }

  // Toggle task completion
  Future<bool> toggleTaskStatus(String taskId) async {
    final task = _tasks.firstWhere((t) => t.id == taskId);
    final newStatus = task.status == 'completed' ? 'pending' : 'completed';

    return await updateTask(task.copyWith(status: newStatus));
  }

  // Set filter
  void setFilter(String status) {
    _filterStatus = status;
    notifyListeners();
  }

  // Set sort
  void setSortBy(String sortBy) {
    _sortBy = sortBy;
    notifyListeners();
  }

  // Get task statistics
  Map<String, int> getTaskStats() {
    return {
      'total': _tasks.length,
      'pending': _tasks.where((t) => t.status == 'pending').length,
      'completed': _tasks.where((t) => t.status == 'completed').length,
      'overdue': _tasks
          .where(
            (t) => t.status == 'pending' && t.dueDate.isBefore(DateTime.now()),
          )
          .length,
    };
  }

  // Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Real-time task updates
  void startListening() {
    if (_auth.currentUser == null) return;

    _firestore
        .collection('tasks')
        .where('userId', isEqualTo: _auth.currentUser!.uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((QuerySnapshot snapshot) {
          _tasks = snapshot.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return Task.fromFirestore(doc.id, data);
          }).toList();
          notifyListeners();
        });
  }
}

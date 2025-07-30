import 'package:flutter/material.dart';
import '../models/task_model.dart';
import 'package:intl/intl.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback? onTap;
  final VoidCallback? onToggle;
  final VoidCallback? onDelete;

  const TaskCard({
    Key? key,
    required this.task,
    this.onTap,
    this.onToggle,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isCompleted = task.status == 'completed';
    final isOverdue = task.isOverdue;

    return Card(
      elevation: 2,
      margin: EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isOverdue ? Colors.red.withOpacity(0.3) : Colors.transparent,
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Task Header
              Row(
                children: [
                  // Completion Checkbox
                  GestureDetector(
                    onTap: onToggle,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isCompleted ? Colors.green : Colors.grey[400]!,
                          width: 2,
                        ),
                        color: isCompleted ? Colors.green : Colors.transparent,
                      ),
                      child: isCompleted
                          ? Icon(Icons.check, size: 16, color: Colors.white)
                          : null,
                    ),
                  ),

                  SizedBox(width: 12),

                  // Task Title
                  Expanded(
                    child: Text(
                      task.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isCompleted ? Colors.grey[600] : Colors.black87,
                        decoration: isCompleted
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                      ),
                    ),
                  ),

                  // Priority Badge
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Task.getPriorityColor(
                        task.priority,
                      ).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Task.getPriorityColor(
                          task.priority,
                        ).withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      task.priority.toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Task.getPriorityColor(task.priority),
                      ),
                    ),
                  ),

                  // More Actions
                  PopupMenuButton<String>(
                    icon: Icon(
                      Icons.more_vert,
                      size: 20,
                      color: Colors.grey[600],
                    ),
                    onSelected: (value) {
                      switch (value) {
                        case 'edit':
                          if (onTap != null) onTap!();
                          break;
                        case 'delete':
                          if (onDelete != null) onDelete!();
                          break;
                        case 'toggle':
                          if (onToggle != null) onToggle!();
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 16, color: Colors.blue),
                            SizedBox(width: 8),
                            Text('Edit'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'toggle',
                        child: Row(
                          children: [
                            Icon(
                              isCompleted ? Icons.undo : Icons.check_circle,
                              size: 16,
                              color: isCompleted ? Colors.orange : Colors.green,
                            ),
                            SizedBox(width: 8),
                            Text(
                              isCompleted ? 'Mark Pending' : 'Mark Complete',
                            ),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 16, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Delete'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // Task Description
              if (task.description.isNotEmpty) ...[
                SizedBox(height: 8),
                Text(
                  task.description,
                  style: TextStyle(
                    fontSize: 14,
                    color: isCompleted ? Colors.grey[500] : Colors.grey[700],
                    decoration: isCompleted
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              SizedBox(height: 12),

              // Task Footer
              Row(
                children: [
                  // Due Date
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isOverdue ? Colors.red[50] : Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isOverdue ? Colors.red[200]! : Colors.grey[300]!,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.schedule,
                          size: 14,
                          color: isOverdue ? Colors.red[700] : Colors.grey[600],
                        ),
                        SizedBox(width: 4),
                        Text(
                          task.formattedDueDate,
                          style: TextStyle(
                            fontSize: 12,
                            color: isOverdue
                                ? Colors.red[700]
                                : Colors.grey[600],
                            fontWeight: isOverdue
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Spacer(),

                  // Status Badge
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Task.getStatusColor(task.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Task.getStatusColor(
                          task.status,
                        ).withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      task.status.toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Task.getStatusColor(task.status),
                      ),
                    ),
                  ),
                ],
              ),

              // Progress Indicator for Overdue Tasks
              if (isOverdue && !isCompleted) ...[
                SizedBox(height: 8),
                Container(
                  height: 2,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

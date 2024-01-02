class Task {
  String name = "";
  bool isTask = false;
  bool taskStatus = false;
  bool frist = false;
  Task(this.name, this.isTask, this.taskStatus, this.frist);
  Task.ofFrist(this.name, this.isTask, this.taskStatus) : frist = true;
  Task.ofTask(this.name, this.taskStatus, this.frist) : isTask = true;
  Task.ofNonFristTask(this.name, this.taskStatus)
      : isTask = true,
        frist = false;
  Task.ofFristTask(
    this.name,
    this.taskStatus,
  )   : isTask = true,
        frist = true;
  Task.ofFristNonTask(
    this.name,
    this.taskStatus,
  )   : isTask = false,
        frist = true;
  Task.fromJson(Map<String, dynamic> json) {
    name = json["name"];
    isTask = json["isTask"];
    taskStatus = json["taskStatus"];
    frist = json["frist"];
  }

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "isTask": isTask,
      "taskStatus": taskStatus,
      "frist": frist,
    };
  }
}

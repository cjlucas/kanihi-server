function updateJobs(jobs)
{
  var html = '';
  html += '<tr><th>ID</th><th>Name</th><th>Priority</th></tr>'
  for (var i=0; i < jobs.length; i++) {
    html += '<tr>';
    var job = jobs[i]['job'];
    html += '<td>' + job.id + '</td>';
    html += '<td>' + job.name + '</td>';
    html += '<td>' + job.priority + '</td>';
    html += '</tr>';
  }

  var elem = $('#jobs');
  elem.html(html);
}

function updateServerStats(serverInfo)
{
  var sidebar = $('#sidebar');
  var html = "<h3>Server Stats</h3>"
  html += "<div>Track Count: " + serverInfo.track_count + "</div>"
  html += "<div>Image Count: " + serverInfo.image_count + "</div>"
  html += "<div>Server Time: " + serverInfo.server_time + "</div>"
  sidebar.html(html);
}

function getServerInfo()
{
  $.getJSON('/info.json', function(data) {
    updateJobs(data['server_info']['jobs']);
    updateServerStats(data['server_info']);
  });
}

setInterval(function() {
  getServerInfo();
}, 2000);

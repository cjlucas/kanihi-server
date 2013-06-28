function updateServerStats(serverInfo)
{
  var sidebar = $('#sidebar');
  var html = "<h3>Server Stats</h3>";
  var date = new Date(serverInfo.server_time);
  html += "<div>Track Count: " + serverInfo.track_count + "</div>";
  html += "<div>Image Count: " + serverInfo.image_count + "</div>";
  //html += "<div>Server Time: " + date.toL + "</div>";
  sidebar.html(html);
}

function updateJobs(jobs)
{
  var html = '';

  for (var i=0; i < jobs.length; i++) {
    var job = jobs[i]['job'];
    html += '<tr>';
    html += '<td>' + job.id + '</td>';
    html += '<td>' + job.name + '</td>';
    html += '<td>' + job.priority + '</td>';
    html += '</tr>';
  }

  if (jobs.length == 0) {
    html = '<tr><td colspan=3><em>No jobs running/pending</em></td></tr>';
  }

  $("table#jobs tr:gt(0)").remove();
  $("table#jobs").append(html);
}

function updateSources(sources)
{
  var html = '';
  for (var i=0; i < sources.length; i++) {
    var source = sources[i]['source'];
    var last_scanned_at = source.last_scanned_at
      ? fmtDate(source.last_scanned_at) : 'Never';
    html += '<tr>';
    html += '<td class="stretch">' + source.location + '</td>';
    html += '<td class="nowrap">' + last_scanned_at + '</td>';
    html += '<td class="nowrap"><a href="#" id="scan_source" ' +
            'data-sourceid="' + source.id + '">Update</a></td>';
    html += '<td class="nowrap"><a href="#" id="delete_source" ' +
            'data-sourceid="' + source.id + '">Delete</a></td>';
    html += '</tr>';
  }

  if (sources.length == 0) {
    html = "<tr><td colspan=4><em>No sources exist</em></td><tr>"
  }

  $("table#sources tr:gt(0)").remove();
  $("table#sources").append(html);
  
  $("#delete_source").click(handleDeleteSource);
  $("#scan_source").click(handleScanSource);
}

function updateDaemons(daemons)
{
  var elem = $("table#daemons");
  // daemons table only exists in debug mode
  if (elem.length == 0)
    return;

  var html = "";
  for (var i=0; i < daemons.length; i++) {
    var daemon = daemons[i]['daemon'];
    html += "<tr>";
    
    html += "<td>" + daemon.name + "</td>";
    if (daemon.pid != null && daemon.dead) {
      html += "<td>" + daemon.pid + " (dead)</td>";
    } else {
      html += "<td>" + daemon.pid + "</td>";
    }

    action = daemon.dead ? "start" : "stop";
    html += "<td><a href='#' data-action='" + action
      + "' data-name='" + daemon.name + "'>" + action + "</a></td>";
    html += "</tr>";
  }

  $("table#daemons tr:gt(0)").remove();
  elem.append(html);

  $("table#daemons a").click(handleDaemonAction);
}

function handleDaemonAction()
{
  var action  = $(this).data("action");
  var name    = $(this).data("name");
  
  $.ajax({
    url: "/daemons/" + action + "?name=" + name,
    type: 'GET',
    async: false,
    success: function(data, textStatus, xhr) {
      setSuccessFlash("Daemons action was successful"); 
    },
    error: function(xhr, textStatus, errorThrown) {
      setErrorFlash("An error occured when perform action on daemon."); 
    },
    complete: function(xhr, textStatus) {
      getServerInfo();
    }
  });
}

function handleDeleteSource()
{
  var src_index = $(this).data("sourceid");
  if (window.confirm("Are you sure you want to delete this source?")) {
    $.ajax({
        url:  '/sources/' + src_index,
        type: 'DELETE',
        async: false,
        success: function(data, textStatus, xhr) {
          setSuccessFlash("Source was successfully deleted."); 
        },
        error: function(xhr, textStatus, errorThrown) {
          setErrorFlash("An error occured when trying to delete source."); 
        },
        complete: function(xhr, textStatus) {
          getServerInfo();
        }
    });
  }
}

function handleScanSource()
{
  var src_index = $(this).data("sourceid");
  $.ajax({
    url: '/sources/' + src_index + '/scan',
    type: 'GET',
    async: false,
    success: function(data, textStatus, xhr) {
      setSuccessFlash('Update job successfully added to queue.');
    },
    error: function(xhr, textStatus, errorThrown) {
      setErrorFlash("An error occured when trying to add update job.");
    },
    complete: function(xhr, textStatus) {
      getServerInfo();
    },
  });
}

function getServerInfo()
{
  $.getJSON('/info.json', function(data) {
    updateJobs(data['server_info']['jobs']);
    updateSources(data['server_info']['sources']);
    updateDaemons(data['server_info']['daemons']);
    updateServerStats(data['server_info']);
  });
}

function fmtDate(date_str)
{
  d = new Date(date_str);
  return d.toRelativeTime();
}

function resetFlash()
{
  var flash = $("#flash");
  flash.text("");
  flash.removeClass('alert-success alert-error alert-warning');
}

function setSuccessFlash(msg)
{
  resetFlash();
  var flash = $("#flash");
  flash.addClass('alert-success');
  setFlashMessage(msg)
  flash.show();
}

function setErrorFlash(msg)
{
  resetFlash();
  var flash = $("#flash");
  flash.addClass('alert-error');
  setFlashMessage(msg)
  flash.show();
}

function setFlashMessage(msg)
{
  var dismissButton = "<button type='button' class='close'>&times;</button>";
  $("#flash").html(msg + dismissButton);
  $("#flash button").click(function() { $("#flash").hide(); });
}

/*
 *setInterval(function() {
 *  getServerInfo();
 *}, 2000);
 */

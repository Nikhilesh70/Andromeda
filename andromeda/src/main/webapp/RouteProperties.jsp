<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    String username = (String) session.getAttribute("username");
    if (username == null || username.trim().isEmpty()) {
        username = "";  // Better than space — makes it clear if it's missing
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8" />
    <title>Route Properties View</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 20px;
            background: #fff;
            color: #333;
        }

        h2 {
            margin-bottom: 20px;
        }

        table.properties {
            width: 100%;
            border-collapse: collapse;
            border: 1px solid #ddd;
            font-size: 14px;
            margin-top: 20px;
        }

        table.properties th,
        table.properties td {
            padding: 12px 16px;
            border: 1px solid #ddd;
            vertical-align: middle;
            text-align: left;
        }

        table.properties th {
            background: #fafafa;
            font-weight: bold;
            width: 180px;
        }

        #loadingSpinner {
            font-size: 14px;
            color: #666;
        }

        #errorMessage {
            color: red;
            font-weight: bold;
            margin-top: 10px;
        }

        .info-box {
            border: 1px solid #ccc;
            border-radius: 5px;
            width: 100%;
            margin-top: 30px;
            overflow-y: auto;
            max-height: 250px;
            box-shadow: 0 1px 3px rgba(0,0,0,0.1);
        }

        .info-header {
            background-color: #f0f0f0;
            font-weight: bold;
            padding: 10px 15px;
            border-bottom: 1px solid #ddd;
            font-size: 16px;
        }

        .info-content {
            padding: 15px;
        }

        .info-content p {
            margin: 8px 0;
            font-size: 14px;
        }
    </style>
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
</head>
<body>
<h2>Properties</h2>
<div id="loadingSpinner">Loading part data...</div>
<div id="errorMessage" style="display:none;"></div>

<!-- Main Properties Table -->
<table id="detailsTable" class="properties" style="display:none;"></table>

<!-- Information and Status Section -->
<div id="statusSection" style="display:none;" class="info-box">
    <div class="info-header">
        Information and Status
    </div>
    <div class="info-content">
        <p><strong>Message:</strong> Approval Request</p>
        <p><strong>Task Assigned:</strong> <span id="taskName">-</span></p>
        <p><strong>Task Assignee:</strong> <span id="assigneeInfo">-</span></p>
        <p><strong>Approval status:</strong> <span id="approvalStatus">-</span></p>
    </div>
</div>
<script>
    const loginUser = "<%= username %>"; 
</script>
<script>
$(document).ready(function () {
    const objectId = getQueryParam('name');
    if (!objectId) {
        showError("No 'name' (ObjectId) parameter found in the URL.");
        return;
    }

    showLoading(true);

    $.ajax({
        url: 'http://localhost:8080/andromeda/api/datafetchservice/getinfospc',
        method: 'GET',
        data: { objectId },
        dataType: 'json',
        success: function (data) {
            if (!data || $.isEmptyObject(data)) {
                showError("No details found for ObjectId: " + objectId);
                return;
            }
            populateTable(data);
            $.ajax({
                url: 'http://localhost:8080/andromeda/api/datafetchservice/checkAssignee',
                method: 'GET',
                data: {
                    objectid: objectId,
                    loginuser: loginUser
                },
                success: function (response) {
                    let isAssignee = false;
                    try {
                        const parsed = typeof response === "string" ? JSON.parse(response) : response;
                        isAssignee = parsed.isAssignee === true;
                    } catch (e) {
                        console.error("Invalid JSON from /checkAssignee", e);
                    }

                    if (isAssignee) {
                        $('#statusSection .info-content p').show(); 
                    } else {
                        $('#statusSection .info-content p:not(:first)').hide(); 
                    }

                    $('#statusSection').show();
                },
                error: function () {
                    console.warn("Assignee check failed");
                    $('#statusSection').hide();
                }
            });
        },
        error: function () {
            showError("Error fetching details.");
        },
        complete: function () {
            showLoading(false);
        }
    });
});

function populateTable(part) {
    const table = $('#detailsTable');
    table.empty();
    $('#errorMessage').hide();

    for (const key in part) {
        if (part.hasOwnProperty(key)) {
            if (['objectid', 'connectionid', 'fts_document', 'linkedobjectid'].includes(key.toLowerCase())) {
                continue;
            }
            if (key.toLowerCase() === 'currentstate' && (!part[key] || part[key].trim() === '')) {
                continue;
            }

            const row = $('<tr>');
            row.append($('<th>').text(prettyLabel(key.toLowerCase())));
            row.append($('<td>').text(part[key] ?? 'N/A'));
            table.append(row);
        }
    }
    table.show();

    const partName = part.name ?? 'NA';
    const assignee = part.assignee ?? 'NA';
    const state = part.currentstate?.toLowerCase() ?? '';

    let approvalStatus = 'Pending';
    if (state.includes('complete') || state.includes('approved') || state.includes('done')) {
        approvalStatus = 'Completed';
    }

    const checkboxIconURL = "https://img.icons8.com/?size=100&id=91kLZWvmd4sg&format=png&color=000000";
    const checkboxIcon = $('<img>')
        .attr('src', checkboxIconURL)
        .attr('alt', 'Approval Checkbox')
        .css({
            width: '20px',
            height: '20px',
            cursor: 'pointer',
            verticalAlign: 'middle',
            marginRight: '8px'
        })
        .on('click', function () {
        	const url = 'AssigneeApproval.jsp?partName=' + encodeURIComponent(partName) + '&assignee=' + encodeURIComponent(assignee);
            window.open(url, 'AssigneeApproval', 'width=700,height=470,position=center,left=100,top=100,resizable=yes');
        });

    $('#taskName').text(partName);
    $('#assigneeInfo').empty().append(checkboxIcon).append(assignee);
    $('#approvalStatus').text(approvalStatus);
}

function getQueryParam(param) {
    return new URLSearchParams(window.location.search).get(param);
}

function showLoading(show) {
    $('#loadingSpinner').css('display', show ? 'block' : 'none');
}

function showError(msg) {
    $('#errorMessage').text(msg).show();
    $('#detailsTable').hide();
    $('#statusSection').hide();
    showLoading(false);
}

function prettyLabel(key) {
    const map = {
        name: "Name",
        supertype: "Supertype",
        type: "Type",
        createddate: "Created Date",
        owner: "Owner",
        description: "Description",
        assignee: "Assignee",
        email: "Email",
        currentstate: "Current State"
    };
    return map[key] || key.charAt(0).toUpperCase() + key.slice(1);
}
</script>
</body>
</html>

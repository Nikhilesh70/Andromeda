<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>AndromedaData</title>

  <!-- jQuery -->
  <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>

  <!-- DataTables CSS & JS -->
  <link rel="stylesheet" href="https://cdn.datatables.net/1.13.6/css/jquery.dataTables.min.css" />
  <script src="https://cdn.datatables.net/1.13.6/js/jquery.dataTables.min.js"></script>

  <style>
  body {
    font-family: Arial, sans-serif;
    max-width: 800px;
    margin: 2em auto;
    background-color: white;  /* <--- Add this line */
  }

  label, input, button {
    display: block;
    margin: 0.5em 0;
  }

  input {
    width: 30%;
    box-sizing: border-box;
    padding: 0.4em;
    font-size: 1em;
  }

  #resultMessage {
    margin-top: 1em;
    font-family: monospace;
  }

  #resultTable_wrapper {
    margin-top: 1em;
  }
</style>
</head>
<body>

  <h2>DataFetchService</h2>

  <label for="objectId">Object ID:</label>
  <input type="text" id="objectId" placeholder="" />

  <label for="field">Field:</label>
  <input type="text" id="field" placeholder="" />

  <button id="fetchBtn">Fetch Data</button>

  <div id="resultContainer">
    <div id="resultMessage"></div>
    <table id="resultTable" class="display" style="width:100%; display: none;">
      <thead>
        <tr>
          <th>Key</th>
          <th>Value</th>
        </tr>
      </thead>
      <tbody></tbody>
    </table>
  </div>
  <script>
    $(document).ready(function () {
      let dataTable;
      $('#fetchBtn').click(function () {
        const objectId = $('#objectId').val().trim();
        const field = $('#field').val().trim();
        const resultMessage = $('#resultMessage');
        const resultTable = $('#resultTable');
        const resultBody = resultTable.find('tbody');
        if (!objectId) {
          alert('Please enter an Object ID');
          return;
        }
        let url = 'http://localhost:8080/andromeda/api/datafetchservice/latestparts';
        let data = { objectId };
        if (field) {
          url += 'info';
          data.field = field;
        } else {
          url += 'all';
        }
        resultMessage.text('Loading...');
        resultTable.hide();
        $.ajax({
          url: url,
          type: 'GET',
          data: data,
          dataType: 'json',
          success: function (response) {
            resultMessage.text('');
            resultBody.empty();
            let rows = [];
            if (field) {
              if (response.hasOwnProperty('value')) {
                rows.push([field, response.value]);
              } else {
                resultMessage.text('Field "' + field + '" not found in response.');
                return;
              }
            } else {
              if (Object.keys(response).length === 0) {
                resultMessage.text('No data available for the given Object ID.');
                return;
              }

              $.each(response, function (key, value) {
                rows.push([key, value]);
              });
            }
            if ($.fn.DataTable.isDataTable('#resultTable')) {
              dataTable.destroy();
            }
            rows.forEach(function (row) {
              resultBody.append('<tr><td>' + row[0] + '</td><td>' + row[1] + '</td></tr>');
            });

            resultTable.show();
            dataTable = $('#resultTable').DataTable({
              paging: false,
              searching: false,
              info: false,
              ordering: true
            });
          },
          error: function (xhr) {
            let errMsg = 'Unknown error occurred';
            if (xhr.responseJSON && xhr.responseJSON.error) {
              errMsg = xhr.responseJSON.error;
            } else if (xhr.statusText) {
              errMsg = xhr.statusText;
            }
            resultMessage.text('Error: ' + errMsg);
            resultTable.hide();
          }
        });
      });
    });
  </script>
</body>
</html>

var userRenderer = function(data, type, row) {
  var displayName = data.role > 0 ? data.name : data.jid;
  return "<a href='/users/" + data.id + "'>" + displayName + "</a>";
};

var dateRenderer = function(data, type, row) {
  return new Date(Date.parse(data)).toLocaleDateString();
};

var paymentRenderer = function(data, type, row) {
  var nextDate = new Date(Date.parse(data));
  var tomorrow = new Date();
  tomorrow.setDate(tomorrow.getDate() + 1);
  if (nextDate <= tomorrow && type === 'display') {
    return '<span class="highlight_date">' + nextDate.toLocaleDateString() + '</span>';
  } 
  return nextDate.toLocaleDateString();
};

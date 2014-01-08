var renderers = {
    user: function(data, type, row) {
        var displayName = data.role > 0 ? data.name : data.jid;
        if (type === 'display') {
            return "<a href='/users/" + data.id + "'>" + displayName + "</a>";
        } else {
            return displayName;
        }
    },

    date: function(data, type, row) {
        if (type === 'display') {
            return new Date(Date.parse(data)).toISOString().replace(/T.*/, '');
        }
        return data;
    },

    nextPaymentDate: function(data, type, row) {
        if (type === 'display') {
            var nextDate = new Date(Date.parse(data));
            var tomorrow = new Date();
            tomorrow.setDate(tomorrow.getDate() + 1);
            var nextDateString = nextDate.toISOString().replace(/T.*/, '');
            if (nextDate <= tomorrow) {
                return '<span class="highlight_date">' + nextDateString + '</span>';
            }
            return nextDateString;
        }
        return data;
    },

    contract: function(data, type, row) {
        if (type === 'display') {
            return "<a href='/contracts/" + data.id + "'>" + data.name.replace(/@conference.syriatalk.biz$/, '') + "</a>";
        }
        return data.name;
    },

    amount: function(data, type, row) {
        if (type === 'display' && data) {
            return '$' + data;
        }
        return data;
    }
}

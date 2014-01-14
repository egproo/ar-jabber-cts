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
        if (type === 'display' && data) {
            var nextDate = new Date(Date.parse(data));
            var tomorrow = new Date();
            tomorrow.setDate(tomorrow.getDate() + 1);
            var nextDateString = nextDate.toISOString().replace(/T.*/, '');
            if (nextDate <= tomorrow) {
                return '<span class="highlight_date">' + nextDateString + '</span>';
            }
            return nextDateString;
        } else if (!data) {
            return '';
        }
        return data;
    },

    contract: function(data, type, row) {
        if (type === 'display') {
            return "<a href='/rooms/" + data.id + "'>" + data.name.replace(/@conference.syriatalk.biz$/, '') + "</a>";
        }
        return data.name;
    },

    amount: function(data, type, row) {
        if (type === 'display' && data != null) {
            return '$' + data;
        } 
        return data;
    },

    lastPaymentAmount: function(data, type, row) {
        var lastPayment = row.last_payment;
        if (type === 'display' && lastPayment) {
            return renderers.amount(lastPayment.amount, type, row);
        } else if (!lastPayment) {
            return '';
        }
        return renderers.amount(lastPayment.amount, type, row);
    },

    lastPaymentDate: function(data, type, row) {
        var lastPaymentDate = row.last_payment;
        if (type === 'display' && lastPaymentDate) {
            return renderers.date(lastPaymentDate.created_at, type, row);
        } else if (!lastPaymentDate) {
            return '';
        }
        return renderers.date(lastPaymentDate.created_at, type, row);
    }
}

package com.careconnect.model.invoice;

import org.junit.jupiter.api.Test;

import static org.assertj.core.api.Assertions.assertThat;

class PaymentStatusTest {

    // ─── All enum values present ───────────────────────────────────────────────

    @Test
    void enumValues_allPresent() throws Exception {
        final PaymentStatus[] values = PaymentStatus.values();

        assertThat(values).containsExactlyInAnyOrder(
                PaymentStatus.PENDING,
                PaymentStatus.OVERDUE,
                PaymentStatus.PENDING_INSURANCE,
                PaymentStatus.SENT,
                PaymentStatus.PAID,
                PaymentStatus.PARTIAL_PAYMENT,
                PaymentStatus.REJECTED_INSURANCE
        );
    }

    // ─── valueOf() ────────────────────────────────────────────────────────────

    @Test
    void valueOf_pending_returnsPending() throws Exception {
        assertThat(PaymentStatus.valueOf("PENDING")).isEqualTo(PaymentStatus.PENDING);
    }

    @Test
    void valueOf_overdue_returnsOverdue() throws Exception {
        assertThat(PaymentStatus.valueOf("OVERDUE")).isEqualTo(PaymentStatus.OVERDUE);
    }

    @Test
    void valueOf_pendingInsurance_returnsPendingInsurance() throws Exception {
        assertThat(PaymentStatus.valueOf("PENDING_INSURANCE")).isEqualTo(PaymentStatus.PENDING_INSURANCE);
    }

    @Test
    void valueOf_sent_returnsSent() throws Exception {
        assertThat(PaymentStatus.valueOf("SENT")).isEqualTo(PaymentStatus.SENT);
    }

    @Test
    void valueOf_paid_returnsPaid() throws Exception {
        assertThat(PaymentStatus.valueOf("PAID")).isEqualTo(PaymentStatus.PAID);
    }

    @Test
    void valueOf_partialPayment_returnsPartialPayment() throws Exception {
        assertThat(PaymentStatus.valueOf("PARTIAL_PAYMENT")).isEqualTo(PaymentStatus.PARTIAL_PAYMENT);
    }

    @Test
    void valueOf_rejectedInsurance_returnsRejectedInsurance() throws Exception {
        assertThat(PaymentStatus.valueOf("REJECTED_INSURANCE")).isEqualTo(PaymentStatus.REJECTED_INSURANCE);
    }

    // ─── name() and ordinal() ─────────────────────────────────────────────────

    @Test
    void name_returnsCorrectString() throws Exception {
        // Java enum name() returns the exact constant identifier (uppercase)
        assertThat(PaymentStatus.PENDING.name()).isEqualTo("PENDING");
        assertThat(PaymentStatus.PAID.name()).isEqualTo("PAID");
        assertThat(PaymentStatus.OVERDUE.name()).isEqualTo("OVERDUE");
    }

    @Test
    void ordinal_isStable() throws Exception {
        assertThat(PaymentStatus.PENDING.ordinal()).isEqualTo(0);
        assertThat(PaymentStatus.OVERDUE.ordinal()).isEqualTo(1);
        assertThat(PaymentStatus.PENDING_INSURANCE.ordinal()).isEqualTo(2);
        assertThat(PaymentStatus.SENT.ordinal()).isEqualTo(3);
        assertThat(PaymentStatus.PAID.ordinal()).isEqualTo(4);
        assertThat(PaymentStatus.PARTIAL_PAYMENT.ordinal()).isEqualTo(5);
        assertThat(PaymentStatus.REJECTED_INSURANCE.ordinal()).isEqualTo(6);
    }

    // ─── Count ────────────────────────────────────────────────────────────────

    @Test
    void enumCount_isSeven() throws Exception {
        assertThat(PaymentStatus.values()).hasSize(7);
    }
}

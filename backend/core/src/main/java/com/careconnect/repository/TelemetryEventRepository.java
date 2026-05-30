package com.careconnect.repository;

import com.careconnect.model.TelemetryEvent;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface TelemetryEventRepository
        extends JpaRepository<TelemetryEvent, Long> {

    /**
     * Returns the 50 most recent telemetry events.
     *
     * @return most recent telemetry events in descending time order
     */
    List<TelemetryEvent> findTop50ByOrderByEventTimeDesc();
}

import Foundation

/// Picks the next remembrance to show, honoring the selection mode and,
/// optionally, the time of day. Keeps a little state across calls
/// (shuffled bag, sequential index, last-shown id) to avoid repeats.
@MainActor
final class DhikrSelector {
    private var bag: [String] = []
    private var lastID: String?
    private var seqIndex = 0

    /// Returns the next dhikr from the enabled `pool`, or nil if the pool is empty.
    func next(from pool: [Dhikr], mode: SelectionMode, timeAware: Bool, hour: Int) -> Dhikr? {
        guard !pool.isEmpty else { return nil }

        // Time-aware: bias toward the time-appropriate category, but fall back to
        // the full pool if that category has no enabled items.
        let effective: [Dhikr]
        if timeAware {
            let preferred = timeFiltered(pool, hour: hour)
            effective = preferred.isEmpty ? pool : preferred
        } else {
            effective = pool
        }

        switch mode {
        case .random:      return randomNoRepeat(effective)
        case .sequential:  return sequential(effective)
        case .shuffledBag: return fromBag(effective)
        }
    }

    private func timeFiltered(_ pool: [Dhikr], hour: Int) -> [Dhikr] {
        switch DayPeriod.current(hour: hour) {
        case .morning: return pool.filter { $0.category == .morning }
        case .evening: return pool.filter { $0.category == .evening }
        case .other:   return []
        }
    }

    private func randomNoRepeat(_ pool: [Dhikr]) -> Dhikr? {
        if pool.count == 1 {
            lastID = pool[0].id
            return pool[0]
        }
        var choice = pool.randomElement()
        while choice?.id == lastID { choice = pool.randomElement() }
        lastID = choice?.id
        return choice
    }

    private func sequential(_ pool: [Dhikr]) -> Dhikr? {
        let sorted = pool.sorted { $0.sortOrder < $1.sortOrder }
        if seqIndex >= sorted.count { seqIndex = 0 }
        let dhikr = sorted[seqIndex]
        seqIndex = (seqIndex + 1) % sorted.count
        lastID = dhikr.id
        return dhikr
    }

    /// Shuffled bag: every item appears once per cycle, no repeats until the bag empties.
    private func fromBag(_ pool: [Dhikr]) -> Dhikr? {
        let poolIDs = Set(pool.map(\.id))
        bag.removeAll { !poolIDs.contains($0) }

        if bag.isEmpty {
            bag = pool.map(\.id).shuffled()
            // Avoid showing the same item twice across a bag boundary.
            if bag.count > 1, bag.first == lastID {
                bag.swapAt(0, bag.count - 1)
            }
        }

        let id = bag.removeFirst()
        lastID = id
        return pool.first { $0.id == id } ?? pool.first
    }
}

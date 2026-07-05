/**
 * Workflow State Machine Template
 * 
 * Follows: workflow-rules.md
 * Generic state machine implementation for any entity with lifecycle states.
 */

export type TransitionMap = Record<string, string[]>;

export interface StateTransition<T extends string> {
  from: T;
  to: T;
  timestamp: string;
  actorId: string;
  reason?: string;
  metadata?: Record<string, unknown>;
}

export class StateMachine<T extends string> {
  private transitions: TransitionMap;
  private currentState: T;
  private history: StateTransition<T>[] = [];

  constructor(initialState: T, transitions: TransitionMap) {
    this.currentState = initialState;
    this.transitions = transitions;
  }

  /**
   * Get the current state
   */
  get state(): T {
    return this.currentState;
  }

  /**
   * Get all valid next states from current state
   */
  get validTransitions(): T[] {
    return (this.transitions[this.currentState] || []) as T[];
  }

  /**
   * Check if a transition is valid
   */
  canTransition(to: T): boolean {
    return this.validTransitions.includes(to);
  }

  /**
   * Execute a state transition
   * Throws if the transition is invalid
   */
  transition(to: T, actorId: string, options?: { reason?: string; metadata?: Record<string, unknown> }): StateTransition<T> {
    if (!this.canTransition(to)) {
      throw new Error(
        `Invalid transition: ${this.currentState} → ${to}. ` +
        `Valid transitions: ${this.validTransitions.join(', ')}`
      );
    }

    const transition: StateTransition<T> = {
      from: this.currentState,
      to,
      timestamp: new Date().toISOString(),
      actorId,
      reason: options?.reason,
      metadata: options?.metadata,
    };

    this.history.push(transition);
    this.currentState = to;

    return transition;
  }

  /**
   * Get the transition history
   */
  getHistory(): StateTransition<T>[] {
    return [...this.history];
  }

  /**
   * Check if the current state is a terminal state (no valid transitions)
   */
  get isTerminal(): boolean {
    return this.validTransitions.length === 0;
  }
}

// ─── Pre-built State Machines ─────────────────────────────────────

import type { WorkOrderStatus, AssetStatus } from '@/db/database';

const WORK_ORDER_TRANSITIONS: TransitionMap = {
  draft:           ['pending', 'cancelled'],
  pending:         ['in_progress', 'cancelled'],
  in_progress:     ['paused', 'pending_parts', 'pending_quote', 'pending_payment', 'completed'],
  paused:          ['in_progress', 'cancelled'],
  pending_parts:   ['in_progress'],
  pending_quote:   ['in_progress', 'cancelled'],
  pending_payment: ['completed'],
  completed:       [],
  cancelled:       [],
};

const ASSET_TRANSITIONS: TransitionMap = {
  registered:  ['active'],
  active:      ['maintenance', 'inactive', 'transferred', 'scrapped'],
  maintenance: ['active', 'inactive'],
  inactive:    ['active', 'scrapped'],
  transferred: ['active'],
  scrapped:    [],
};

export function createWorkOrderStateMachine(initialState: WorkOrderStatus) {
  return new StateMachine(initialState, WORK_ORDER_TRANSITIONS);
}

export function createAssetStateMachine(initialState: AssetStatus) {
  return new StateMachine(initialState, ASSET_TRANSITIONS);
}
